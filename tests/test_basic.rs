use actix_web::{test, App};

#[actix_web::test]
async fn test_index_ok() {
    // Import your app and handler
    use devops_takehome::{index}; // Update with your crate name and handler path

    // Build the app for testing
    let app = test::init_service(App::new().service(index)).await;

    // Create a test GET request to "/"
    let req = test::TestRequest::get().uri("/").to_request();

    // Send the request and get the response
    let resp = test::call_service(&app, req).await;

    // Check the HTTP status is 200 OK
    assert!(resp.status().is_success());

    // Read the response body
    let body = test::read_body(resp).await;

    // Check the response body content
    assert_eq!(body, "Hello, DevOps candidate!");
}
