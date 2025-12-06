import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import { useState } from 'react';
import Layout from '../components/Layout/Layout';

const LoginPage = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const message = location.state?.message;

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm();

  const onSubmit = async (data) => {
    setError('');
    setLoading(true);

    try {
      // TODO: Implement login API call
      console.log('Login data:', data);
      // For now, just show a message
      setError('Chức năng đăng nhập sẽ được triển khai sau');
    } catch (err) {
      setError('Đăng nhập thất bại. Vui lòng thử lại.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Layout>
      <div className="min-h-screen flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="max-w-md w-full space-y-8">
          <div>
            <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
              Đăng Nhập
            </h2>
            <p className="mt-2 text-center text-sm text-gray-600">
              Chưa có tài khoản?{' '}
              <Link
                to="/register"
                className="font-medium text-primary-600 hover:text-primary-500"
              >
                Đăng ký ngay
              </Link>
            </p>
          </div>

          <form className="mt-8 space-y-6" onSubmit={handleSubmit(onSubmit)}>
            {message && (
              <div className="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-lg">
                {message}
              </div>
            )}

            {error && (
              <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                {error}
              </div>
            )}

            <div className="space-y-4">
              <div>
                <label htmlFor="email" className="label">
                  Email
                </label>
                <input
                  id="email"
                  type="email"
                  className={`input ${errors.email ? 'border-red-500' : ''}`}
                  {...register('email', {
                    required: 'Email là bắt buộc',
                    pattern: {
                      value: /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/i,
                      message: 'Email không đúng định dạng',
                    },
                  })}
                />
                {errors.email && (
                  <p className="error-text">{errors.email.message}</p>
                )}
              </div>

              <div>
                <label htmlFor="password" className="label">
                  Mật khẩu
                </label>
                <input
                  id="password"
                  type="password"
                  className={`input ${errors.password ? 'border-red-500' : ''}`}
                  {...register('password', {
                    required: 'Mật khẩu là bắt buộc',
                    minLength: {
                      value: 8,
                      message: 'Mật khẩu phải có ít nhất 8 ký tự',
                    },
                    maxLength: {
                      value: 16,
                      message: 'Mật khẩu không được vượt quá 16 ký tự',
                    },
                  })}
                />
                {errors.password && (
                  <p className="error-text">{errors.password.message}</p>
                )}
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full btn btn-primary py-3 text-lg disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Đang xử lý...' : 'Đăng Nhập'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Layout>
  );
};

export default LoginPage;

