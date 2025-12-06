import { Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

const LandingPage = () => {
  const { isAuthenticated } = useAuth();

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary-600 to-primary-800 text-white py-20">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h1 className="text-5xl font-bold mb-6">
              Hệ Thống Quản Lý Thư Viện
            </h1>
            <p className="text-xl mb-8 text-primary-100">
              Quản lý mượn trả sách một cách hiện đại, nhanh chóng và tiện lợi.
              Tìm kiếm sách, mượn sách và quản lý tài khoản của bạn chỉ với vài cú click.
            </p>
            <div className="flex gap-4 justify-center">
              {!isAuthenticated ? (
                <>
                  <Link to="/register" className="btn bg-white text-primary-600 hover:bg-gray-100 px-8 py-3 text-lg">
                    Bắt Đầu Ngay
                  </Link>
                  <Link to="/books" className="btn btn-outline border-white text-white hover:bg-white/10 px-8 py-3 text-lg">
                    Xem Sách
                  </Link>
                </>
              ) : (
                <Link to="/books" className="btn bg-white text-primary-600 hover:bg-gray-100 px-8 py-3 text-lg">
                  Xem Sách
                </Link>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-white">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            Tính Năng Nổi Bật
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">📖</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Tìm Kiếm Sách Dễ Dàng</h3>
              <p className="text-gray-600">
                Tìm kiếm sách theo tên, tác giả hoặc thể loại một cách nhanh chóng.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">🔄</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Mượn Trả Trực Tuyến</h3>
              <p className="text-gray-600">
                Mượn và trả sách trực tuyến, không cần đến thư viện để đăng ký.
              </p>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-primary-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <span className="text-3xl">📊</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Theo Dõi Lịch Sử</h3>
              <p className="text-gray-600">
                Xem lịch sử mượn sách, hạn trả và các khoản phạt của bạn.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section className="py-20 bg-gray-50">
        <div className="container mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">
            Cách Thức Hoạt Động
          </h2>
          <div className="max-w-4xl mx-auto">
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="text-center">
                <div className="w-12 h-12 bg-primary-600 text-white rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                  1
                </div>
                <h3 className="text-lg font-semibold mb-2">Đăng Ký Tài Khoản</h3>
                <p className="text-gray-600">
                  Tạo tài khoản miễn phí chỉ với email và mật khẩu.
                </p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 bg-primary-600 text-white rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                  2
                </div>
                <h3 className="text-lg font-semibold mb-2">Tìm Kiếm Sách</h3>
                <p className="text-gray-600">
                  Duyệt qua danh sách sách và tìm cuốn sách bạn muốn mượn.
                </p>
              </div>
              <div className="text-center">
                <div className="w-12 h-12 bg-primary-600 text-white rounded-full flex items-center justify-center mx-auto mb-4 text-xl font-bold">
                  3
                </div>
                <h3 className="text-lg font-semibold mb-2">Mượn Sách</h3>
                <p className="text-gray-600">
                  Gửi yêu cầu mượn sách và chờ xác nhận từ nhân viên thư viện.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      {!isAuthenticated && (
        <section className="py-20 bg-primary-600 text-white">
          <div className="container mx-auto px-4 text-center">
            <h2 className="text-3xl font-bold mb-4">
              Sẵn Sàng Bắt Đầu?
            </h2>
            <p className="text-xl mb-8 text-primary-100">
              Đăng ký ngay để trải nghiệm hệ thống quản lý thư viện hiện đại.
            </p>
            <Link
              to="/register"
              className="btn bg-white text-primary-600 hover:bg-gray-100 px-8 py-3 text-lg inline-block"
            >
              Đăng Ký Ngay
            </Link>
          </div>
        </section>
      )}
    </div>
  );
};

export default LandingPage;

