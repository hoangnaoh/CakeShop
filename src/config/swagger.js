import swaggerJsdoc from 'swagger-jsdoc';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Fashion Rental API',
      version: '1.0.0',
      description: 'API documentation cho hệ thống Fashion Rental (B2C & C2C)',
    },
    servers: [
      {
        url: 'http://localhost:5000/api/v1',
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
    security: [
      {
        bearerAuth: [],
      },
    ],
  },
  apis: ['./src/routes/*.js'], // Quét toàn bộ file route để tìm JSDoc
};

export const swaggerSpec = swaggerJsdoc(options);
