import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { Link, useNavigate } from 'react-router-dom';
import api from '../config/axios';
import Layout from '../components/Layout/Layout';

const RegisterPage = () => {
  const navigate = useNavigate();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const {
    register,
    handleSubmit,
    watch,
    formState: { errors },
  } = useForm();

  const password = watch('password');

  const onSubmit = async (data) => {
    setError('');
    setLoading(true);

    try {
      const response = await api.post('/auth/register', {
        email: data.email,
        name: data.name,
        password: data.password,
        confirmPassword: data.confirmPassword,
      });

      if (response.data.success) {
        // Redirect to login page
        navigate('/login', {
          state: { message: 'Đăng ký thành công! Vui lòng đăng nhập.' },
        });
      }
    } catch (err) {
      if (err.response?.data?.message) {
        setError(err.response.data.message);
      } else if (err.response?.data?.errors) {
        setError(err.response.data.errors[0]?.message || 'Có lỗi xảy ra');
      } else {
        setError('Đăng ký thất bại. Vui lòng thử lại.');
      }
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
              Đăng Ký Tài Khoản
            </h2>
            <p className="mt-2 text-center text-sm text-gray-600">
              Đã có tài khoản?{' '}
              <Link
                to="/login"
                className="font-medium text-primary-600 hover:text-primary-500"
              >
                Đăng nhập ngay
              </Link>
            </p>
          </div>

          <form className="mt-8 space-y-6" onSubmit={handleSubmit(onSubmit)}>
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
                <label htmlFor="name" className="label">
                  Tên
                </label>
                <input
                  id="name"
                  type="text"
                  className={`input ${errors.name ? 'border-red-500' : ''}`}
                  {...register('name', {
                    required: 'Tên là bắt buộc',
                    maxLength: {
                      value: 50,
                      message: 'Tên không được vượt quá 50 ký tự',
                    },
                  })}
                />
                {errors.name && (
                  <p className="error-text">{errors.name.message}</p>
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

              <div>
                <label htmlFor="confirmPassword" className="label">
                  Xác nhận mật khẩu
                </label>
                <input
                  id="confirmPassword"
                  type="password"
                  className={`input ${
                    errors.confirmPassword ? 'border-red-500' : ''
                  }`}
                  {...register('confirmPassword', {
                    required: 'Xác nhận mật khẩu là bắt buộc',
                    validate: (value) =>
                      value === password || 'Mật khẩu xác nhận không khớp',
                  })}
                />
                {errors.confirmPassword && (
                  <p className="error-text">
                    {errors.confirmPassword.message}
                  </p>
                )}
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full btn btn-primary py-3 text-lg disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {loading ? 'Đang xử lý...' : 'Đăng Ký'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </Layout>
  );
};

export default RegisterPage;

