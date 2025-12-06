-- ============================================================================
-- Library Management System - Database Schema
-- PostgreSQL / Supabase Migration Script
-- ============================================================================
-- This script creates all tables, indexes, RLS policies, and triggers
-- for the library management system.
-- ============================================================================

-- Enable UUID extension (if not already enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- ENUMS
-- ============================================================================

-- User roles
CREATE TYPE user_role AS ENUM ('reader', 'librarian', 'admin');

-- User status
CREATE TYPE user_status AS ENUM ('active', 'inactive');

-- Book status
CREATE TYPE book_status AS ENUM ('available', 'damaged', 'lost');

-- Borrow status
CREATE TYPE borrow_status AS ENUM ('pending', 'approved', 'rejected', 'borrowed', 'returned');

-- Return request status
CREATE TYPE return_request_status AS ENUM ('pending', 'confirmed');

-- Penalty reason
CREATE TYPE penalty_reason AS ENUM ('late_return', 'damaged', 'lost');

-- Penalty status
CREATE TYPE penalty_status AS ENUM ('unpaid', 'pending', 'paid', 'rejected');

-- ============================================================================
-- TABLES (in dependency order)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- users: User profiles extending Supabase Auth
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    auth_user_id UUID NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    address VARCHAR(255),
    role user_role NOT NULL DEFAULT 'reader',
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT users_name_length CHECK (char_length(name) > 0 AND char_length(name) <= 50),
    CONSTRAINT users_address_length CHECK (address IS NULL OR char_length(address) <= 255)
);

COMMENT ON TABLE users IS 'User profiles extending Supabase Auth. Links to auth.users via auth_user_id.';
COMMENT ON COLUMN users.auth_user_id IS 'Foreign key to auth.users(id) - managed by Supabase Auth';
COMMENT ON COLUMN users.role IS 'User role: reader, librarian, or admin';
COMMENT ON COLUMN users.status IS 'Account status: active or inactive';

-- ----------------------------------------------------------------------------
-- categories: Book categories
-- ----------------------------------------------------------------------------
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT categories_name_length CHECK (char_length(name) > 0 AND char_length(name) <= 50)
);

COMMENT ON TABLE categories IS 'Book categories for organizing the library collection';
COMMENT ON COLUMN categories.name IS 'Category name (max 50 characters)';

-- ----------------------------------------------------------------------------
-- books: Books in the library
-- ----------------------------------------------------------------------------
CREATE TABLE books (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(17), -- ISBN-10 (10 chars) or ISBN-13 (13 chars) with hyphens
    publication_year INTEGER,
    description TEXT NOT NULL,
    total_quantity INTEGER NOT NULL DEFAULT 0,
    available_quantity INTEGER NOT NULL DEFAULT 0,
    borrowed_quantity INTEGER NOT NULL DEFAULT 0,
    status book_status NOT NULL DEFAULT 'available',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT books_title_length CHECK (char_length(title) > 0 AND char_length(title) <= 100),
    CONSTRAINT books_author_length CHECK (char_length(author) > 0 AND char_length(author) <= 100),
    CONSTRAINT books_description_length CHECK (char_length(description) > 0 AND char_length(description) <= 500),
    CONSTRAINT books_publication_year CHECK (publication_year IS NULL OR (publication_year >= 1900 AND publication_year <= EXTRACT(YEAR FROM now()))),
    CONSTRAINT books_total_quantity_positive CHECK (total_quantity >= 0),
    CONSTRAINT books_available_quantity_positive CHECK (available_quantity >= 0),
    CONSTRAINT books_borrowed_quantity_positive CHECK (borrowed_quantity >= 0),
    CONSTRAINT books_quantity_consistency CHECK (available_quantity + borrowed_quantity <= total_quantity)
);

COMMENT ON TABLE books IS 'Books in the library collection';
COMMENT ON COLUMN books.isbn IS 'ISBN-10 or ISBN-13 (optional)';
COMMENT ON COLUMN books.total_quantity IS 'Total copies owned by the library';
COMMENT ON COLUMN books.available_quantity IS 'Copies currently available for borrowing';
COMMENT ON COLUMN books.borrowed_quantity IS 'Copies currently borrowed';

-- ----------------------------------------------------------------------------
-- borrows: Borrowing records
-- ----------------------------------------------------------------------------
CREATE TABLE borrows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    book_id UUID NOT NULL REFERENCES books(id) ON DELETE RESTRICT,
    status borrow_status NOT NULL DEFAULT 'pending',
    borrow_date DATE,
    due_date DATE,
    return_date DATE,
    duration_days INTEGER NOT NULL DEFAULT 14,
    rejection_reason TEXT,
    extension_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT borrows_duration_days CHECK (duration_days >= 1 AND duration_days <= 30),
    CONSTRAINT borrows_extension_count CHECK (extension_count <= 1),
    CONSTRAINT borrows_rejection_reason_length CHECK (rejection_reason IS NULL OR char_length(rejection_reason) <= 500),
    CONSTRAINT borrows_dates_consistency CHECK (
        (status = 'pending' AND borrow_date IS NULL AND due_date IS NULL AND return_date IS NULL) OR
        (status = 'rejected' AND borrow_date IS NULL AND due_date IS NULL AND return_date IS NULL) OR
        (status IN ('approved', 'borrowed', 'returned') AND borrow_date IS NOT NULL AND due_date IS NOT NULL) OR
        (status = 'returned' AND return_date IS NOT NULL)
    )
);

COMMENT ON TABLE borrows IS 'Borrowing records tracking book loans';
COMMENT ON COLUMN borrows.status IS 'Current state: pending → approved/rejected → borrowed → returned';
COMMENT ON COLUMN borrows.duration_days IS 'Loan period in days (1-30)';
COMMENT ON COLUMN borrows.extension_count IS 'Number of extensions (max 1)';
COMMENT ON COLUMN borrows.rejection_reason IS 'Reason if borrow request was rejected';

-- ----------------------------------------------------------------------------
-- return_requests: Return requests
-- ----------------------------------------------------------------------------
CREATE TABLE return_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    borrow_id UUID NOT NULL UNIQUE REFERENCES borrows(id) ON DELETE CASCADE,
    status return_request_status NOT NULL DEFAULT 'pending',
    request_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    confirmed_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT return_requests_borrow_status CHECK (
        (status = 'pending' AND confirmed_date IS NULL) OR
        (status = 'confirmed' AND confirmed_date IS NOT NULL)
    )
);

COMMENT ON TABLE return_requests IS 'Return requests initiated by readers';
COMMENT ON COLUMN return_requests.borrow_id IS 'Associated borrow record (one return request per borrow)';

-- ----------------------------------------------------------------------------
-- penalty_levels: Penalty level configurations
-- ----------------------------------------------------------------------------
CREATE TABLE penalty_levels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(25) NOT NULL UNIQUE,
    amount DECIMAL(10, 2) NOT NULL,
    effective_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT penalty_levels_name_length CHECK (char_length(name) > 0 AND char_length(name) <= 25),
    CONSTRAINT penalty_levels_amount_positive CHECK (amount > 0)
);

COMMENT ON TABLE penalty_levels IS 'Configurable penalty amounts for different violation types';
COMMENT ON COLUMN penalty_levels.name IS 'Penalty level name (max 25 characters)';
COMMENT ON COLUMN penalty_levels.effective_date IS 'When this penalty level becomes active';

-- ----------------------------------------------------------------------------
-- penalties: Penalty records
-- ----------------------------------------------------------------------------
CREATE TABLE penalties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    borrow_id UUID REFERENCES borrows(id) ON DELETE SET NULL,
    penalty_level_id UUID NOT NULL REFERENCES penalty_levels(id) ON DELETE RESTRICT,
    reason penalty_reason NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    status penalty_status NOT NULL DEFAULT 'unpaid',
    notes TEXT,
    rejection_reason TEXT,
    payment_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    
    CONSTRAINT penalties_amount_positive CHECK (amount > 0),
    CONSTRAINT penalties_notes_length CHECK (notes IS NULL OR char_length(notes) <= 500),
    CONSTRAINT penalties_rejection_reason_length CHECK (rejection_reason IS NULL OR char_length(rejection_reason) <= 500),
    CONSTRAINT penalties_status_consistency CHECK (
        (status = 'unpaid' AND payment_date IS NULL) OR
        (status = 'pending' AND payment_date IS NULL) OR
        (status = 'paid' AND payment_date IS NOT NULL) OR
        (status = 'rejected' AND payment_date IS NULL)
    ),
    CONSTRAINT penalties_notes_required CHECK (
        (reason IN ('damaged', 'lost') AND notes IS NOT NULL) OR
        (reason = 'late_return')
    )
);

COMMENT ON TABLE penalties IS 'Penalty records for violations (late return, damage, loss)';
COMMENT ON COLUMN penalties.borrow_id IS 'Associated borrow (nullable for system penalties)';
COMMENT ON COLUMN penalties.reason IS 'Type of violation: late_return, damaged, or lost';
COMMENT ON COLUMN penalties.notes IS 'Librarian notes (required for damage/loss)';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- users indexes
CREATE UNIQUE INDEX idx_users_auth_user_id ON users(auth_user_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_role_status ON users(role, status);

-- categories indexes
CREATE UNIQUE INDEX idx_categories_name ON categories(name);

-- books indexes
CREATE INDEX idx_books_category_id ON books(category_id);
CREATE INDEX idx_books_status ON books(status);
CREATE INDEX idx_books_title_author ON books(title, author);
CREATE INDEX idx_books_isbn ON books(isbn) WHERE isbn IS NOT NULL;

-- borrows indexes
CREATE INDEX idx_borrows_user_id ON borrows(user_id);
CREATE INDEX idx_borrows_book_id ON borrows(book_id);
CREATE INDEX idx_borrows_status ON borrows(status);
CREATE INDEX idx_borrows_due_date ON borrows(due_date);
CREATE INDEX idx_borrows_user_status ON borrows(user_id, status);
CREATE INDEX idx_borrows_book_status ON borrows(book_id, status);

-- return_requests indexes
CREATE UNIQUE INDEX idx_return_requests_borrow_id ON return_requests(borrow_id);
CREATE INDEX idx_return_requests_status ON return_requests(status);

-- penalty_levels indexes
CREATE UNIQUE INDEX idx_penalty_levels_name ON penalty_levels(name);
CREATE INDEX idx_penalty_levels_effective_date ON penalty_levels(effective_date);

-- penalties indexes
CREATE INDEX idx_penalties_user_id ON penalties(user_id);
CREATE INDEX idx_penalties_borrow_id ON penalties(borrow_id) WHERE borrow_id IS NOT NULL;
CREATE INDEX idx_penalties_status ON penalties(status);
CREATE INDEX idx_penalties_user_status ON penalties(user_id, status);
CREATE INDEX idx_penalties_penalty_level_id ON penalties(penalty_level_id);

-- ============================================================================
-- FUNCTIONS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_updated_at_column() IS 'Trigger function to automatically update updated_at timestamp';

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Auto-update updated_at for all tables
CREATE TRIGGER trigger_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_categories_updated_at
    BEFORE UPDATE ON categories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_borrows_updated_at
    BEFORE UPDATE ON borrows
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_return_requests_updated_at
    BEFORE UPDATE ON return_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_penalty_levels_updated_at
    BEFORE UPDATE ON penalty_levels
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_penalties_updated_at
    BEFORE UPDATE ON penalties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE books ENABLE ROW LEVEL SECURITY;
ALTER TABLE borrows ENABLE ROW LEVEL SECURITY;
ALTER TABLE return_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE penalty_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE penalties ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- RLS POLICIES - users
-- ============================================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
    ON users FOR SELECT
    USING (auth_user_id = auth.uid());

-- Users can create their own profile (during registration)
CREATE POLICY "Users can create own profile"
    ON users FOR INSERT
    WITH CHECK (
        auth_user_id = auth.uid() AND
        role = 'reader' AND
        status = 'active'
    );

-- Users can update their own profile (but not role/status)
CREATE POLICY "Users can update own profile"
    ON users FOR UPDATE
    USING (auth_user_id = auth.uid())
    WITH CHECK (
        auth_user_id = auth.uid() AND
        role = (SELECT role FROM users WHERE auth_user_id = auth.uid()) AND
        status = (SELECT status FROM users WHERE auth_user_id = auth.uid())
    );

-- Librarians and admins can view all users
CREATE POLICY "Librarians and admins can view all users"
    ON users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians and admins can insert users (for registration approval)
CREATE POLICY "Librarians and admins can insert users"
    ON users FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Only admins can update user roles and status
CREATE POLICY "Admins can update user roles and status"
    ON users FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role = 'admin'
        )
    );

-- Only admins can delete users
CREATE POLICY "Admins can delete users"
    ON users FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role = 'admin'
        )
    );

-- ============================================================================
-- RLS POLICIES - categories
-- ============================================================================

-- Everyone can view categories (public)
CREATE POLICY "Everyone can view categories"
    ON categories FOR SELECT
    USING (true);

-- Only librarians and admins can manage categories
CREATE POLICY "Librarians and admins can manage categories"
    ON categories FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ============================================================================
-- RLS POLICIES - books
-- ============================================================================

-- Everyone can view books (public)
CREATE POLICY "Everyone can view books"
    ON books FOR SELECT
    USING (true);

-- Only librarians and admins can manage books
CREATE POLICY "Librarians and admins can manage books"
    ON books FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ============================================================================
-- RLS POLICIES - borrows
-- ============================================================================

-- Users can view their own borrows
CREATE POLICY "Users can view own borrows"
    ON borrows FOR SELECT
    USING (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
    );

-- Users can create their own borrow requests
CREATE POLICY "Users can create own borrow requests"
    ON borrows FOR INSERT
    WITH CHECK (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
    );

-- Librarians and admins can view all borrows
CREATE POLICY "Librarians and admins can view all borrows"
    ON borrows FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians and admins can update borrows (approve/reject/confirm return)
CREATE POLICY "Librarians and admins can update borrows"
    ON borrows FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Users can update their own borrows (for extensions)
CREATE POLICY "Users can extend own borrows"
    ON borrows FOR UPDATE
    USING (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
        AND status = 'borrowed'
    )
    WITH CHECK (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
        AND status = 'borrowed'
        AND extension_count <= 1
    );

-- ============================================================================
-- RLS POLICIES - return_requests
-- ============================================================================

-- Users can view their own return requests
CREATE POLICY "Users can view own return requests"
    ON return_requests FOR SELECT
    USING (
        borrow_id IN (
            SELECT id FROM borrows
            WHERE user_id IN (
                SELECT id FROM users WHERE auth_user_id = auth.uid()
            )
        )
    );

-- Users can create their own return requests
CREATE POLICY "Users can create own return requests"
    ON return_requests FOR INSERT
    WITH CHECK (
        borrow_id IN (
            SELECT id FROM borrows
            WHERE user_id IN (
                SELECT id FROM users WHERE auth_user_id = auth.uid()
            )
            AND status = 'borrowed'
        )
    );

-- Librarians and admins can view all return requests
CREATE POLICY "Librarians and admins can view all return requests"
    ON return_requests FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians and admins can update return requests (confirm return)
CREATE POLICY "Librarians and admins can update return requests"
    ON return_requests FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ============================================================================
-- RLS POLICIES - penalty_levels
-- ============================================================================

-- Everyone can view penalty levels (public)
CREATE POLICY "Everyone can view penalty levels"
    ON penalty_levels FOR SELECT
    USING (true);

-- Only admins can manage penalty levels
CREATE POLICY "Admins can manage penalty levels"
    ON penalty_levels FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role = 'admin'
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role = 'admin'
        )
    );

-- ============================================================================
-- RLS POLICIES - penalties
-- ============================================================================

-- Users can view their own penalties
CREATE POLICY "Users can view own penalties"
    ON penalties FOR SELECT
    USING (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
    );

-- Users can update their own penalties (mark as paid/pending)
CREATE POLICY "Users can update own penalties"
    ON penalties FOR UPDATE
    USING (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
    )
    WITH CHECK (
        user_id IN (
            SELECT id FROM users WHERE auth_user_id = auth.uid()
        )
        AND status IN ('pending', 'unpaid') -- Users can only change to pending
    );

-- Librarians and admins can view all penalties
CREATE POLICY "Librarians and admins can view all penalties"
    ON penalties FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians and admins can create penalties
CREATE POLICY "Librarians and admins can create penalties"
    ON penalties FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- Librarians and admins can update penalties (confirm payment/reject)
CREATE POLICY "Librarians and admins can update penalties"
    ON penalties FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM users
            WHERE auth_user_id = auth.uid()
            AND role IN ('librarian', 'admin')
        )
    );

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================

