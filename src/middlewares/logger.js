import morgan from 'morgan';

const logger = (app) => {
  app.use(morgan('dev'));
};

export default logger;