class EndPoints {
  static const _baseEndPoint = 'https://ecommerce-rendered.onrender.com'; 
  // static const _baseEndPoint = 'http://localhost:3000'; 

// All Get End Points
  static const getAllProductsEndPoint = '$_baseEndPoint/products';
  static const orderslistEndPoint = '$_baseEndPoint/orderslist';
  static const orderlistEndPoint = '$_baseEndPoint/orderlist';
  static const bookingCartsEndPoint = '$_baseEndPoint/bookingcarts';

  static const orderlistStatusEndPoint = '$_baseEndPoint/orderlist/status';
  static const stockUpdateEndPoint = '$_baseEndPoint/stock-update';
  static const reviewsEndPoint = '$_baseEndPoint/reviews';
}
