# test_app.py

def test_message():
    message = "Hello from Jenkins Python build!"
    assert message == "Hello from Jenkins Python build!"

if __name__ == "__main__":
    test_message()
    print("✅ Test passed successfully!")
