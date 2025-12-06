import Joi from 'joi';

export const registerSchema = Joi.object({
  email: Joi.string()
    .email()
    .required()
    .messages({
      'string.email': 'Email không đúng định dạng',
      'any.required': 'Email là bắt buộc',
    }),
  name: Joi.string()
    .min(1)
    .max(50)
    .required()
    .messages({
      'string.min': 'Tên không được để trống',
      'string.max': 'Tên không được vượt quá 50 ký tự',
      'any.required': 'Tên là bắt buộc',
    }),
  password: Joi.string()
    .min(8)
    .max(16)
    .required()
    .messages({
      'string.min': 'Mật khẩu phải có ít nhất 8 ký tự',
      'string.max': 'Mật khẩu không được vượt quá 16 ký tự',
      'any.required': 'Mật khẩu là bắt buộc',
    }),
  confirmPassword: Joi.string()
    .valid(Joi.ref('password'))
    .required()
    .messages({
      'any.only': 'Mật khẩu xác nhận không khớp',
      'any.required': 'Xác nhận mật khẩu là bắt buộc',
    }),
});

export const validate = (schema) => {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      return res.status(400).json({
        success: false,
        message: 'Validation error',
        errors: error.details.map((detail) => ({
          field: detail.path.join('.'),
          message: detail.message,
        })),
      });
    }

    req.body = value;
    next();
  };
};

