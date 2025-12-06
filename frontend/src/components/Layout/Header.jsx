import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const Header = () => {
  const { user, logout, isAuthenticated } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <header className="bg-white shadow-sm sticky top-0 z-50">
      <div className="container mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          <Link to="/" className="flex items-center space-x-2">
            <div className="w-10 h-10 bg-primary-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-xl">📚</span>
            </div>
            <span className="text-xl font-bold text-gray-900">Thư Viện</span>
          </Link>

          <nav className="flex items-center space-x-6">
            {!isAuthenticated ? (
              <>
                <Link
                  to="/books"
                  className="text-gray-700 hover:text-primary-600 transition-colors"
                >
                  Sách
                </Link>
                <Link
                  to="/login"
                  className="text-gray-700 hover:text-primary-600 transition-colors"
                >
                  Đăng Nhập
                </Link>
                <Link
                  to="/register"
                  className="btn btn-primary"
                >
                  Đăng Ký
                </Link>
              </>
            ) : (
              <>
                <Link
                  to="/books"
                  className="text-gray-700 hover:text-primary-600 transition-colors"
                >
                  Sách
                </Link>
                {user?.role === 'reader' && (
                  <Link
                    to="/my-books"
                    className="text-gray-700 hover:text-primary-600 transition-colors"
                  >
                    Sách Của Tôi
                  </Link>
                )}
                {(user?.role === 'librarian' || user?.role === 'admin') && (
                  <Link
                    to="/dashboard"
                    className="text-gray-700 hover:text-primary-600 transition-colors"
                  >
                    Dashboard
                  </Link>
                )}
                <div className="flex items-center space-x-4">
                  <span className="text-gray-700">
                    Xin chào, <span className="font-medium">{user?.name}</span>
                  </span>
                  <button
                    onClick={handleLogout}
                    className="btn btn-outline"
                  >
                    Đăng Xuất
                  </button>
                </div>
              </>
            )}
          </nav>
        </div>
      </div>
    </header>
  );
};

export default Header;

