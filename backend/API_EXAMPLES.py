"""
api URL:  http://127.0.0.1:5000/api/create_user
body:
    {
        "firstname" :"obied",
        "password" : "haddad",
        "phonenum" : "0509021620"
    }

response:
    {
        'message': 'User created successfully',
        'username': "obied",
        'phonenum': "0509021620"
    }

other response:
    {
        "error": "User with this username already exists"
    }

api URL:  http://127.0.0.1:5000/api/user_verfication
body:
    {
        "username" :"obied",
        "password" : "haddad",
    }

response:
    {
        "message": "User Verified",
        "user_type": "regular",
        "userid": "e7f67d04-341d-4f00-b022-ee1af42f6141"
    }

other response:
    {
        "error": "Invalid username or password"
    }

api URL: http://127.0.0.1:5000/api/update_preference
body:
    {
        "username": "obied",
        "preference": "wifi-1, parking-0, showers"
    }

response:
    {
        "message": "Preference updated successfully"
    }

other response:
    {
        "error": "User ID and preference are required"
    }

other response:
    {
        "error": "User ID must be a valid UUID"
    }

api_url: http://localhost:5000/api/create_field
body:
    {
        "name": "adi club",
        "location": "adi",
        "latitude": "37.23.55",
        "longitude": "-122.0373",
        "sport_type": "tennis",
        "conf_interval": "14:00-16:00, 50, 16:00-18:00, 45, 19:00-20:00, 60, 22:00-00:00, 30",
        "imageURL": "lib/images/samir_stadium.jpg",
        "manager_id": "some-manager-uuid",
        "utilities": {
            "Pool": 0,
            "Lights": 0,
            "Bathroom": 1,
            "Sport equipment": 1,
            "Free parking": 0
        }
    }
response:
    {
        "message": "Field created successfully"
    }

other response:
    {
        "error": "Field with the same name, location, and sport type already exists"
    }
OR:
    {
        "error": "Manager ID must be a valid UUID"
    }

api URL: http://127.0.0.1:5000/api/update_conf_interval
body:
    {
        "field_id": "some-field-uuid",
        "conf_interval": "14:00-15:00,50 15:00-16:00,60 08:00-09:00,5"
    }

response:
    {
        "imageURL": "lib/images/samir_stadium.jpg",
        "latitude": "17.53.85",
        "location": "shefa-amr",
        "longitude": "-191.1373",
        "name": "shefa club",
        "sport_type": "tennis",
        "uid": "94154805-8c01-4653-8592-feb960805ea8",
        "utilities": {
            "Bathroom": 1,
            "Free parking": 0,
            "Lights": 0,
            "Pool": 0,
            "Sport equipment": 1
        }
    }

other response:
    {
        "message": "Field not found"
    }
OR:
    {
        "error": "Field ID is required"
    }
OR:
    {
        "error": "Field ID must be a valid UUID"
    }


api URL: http://127.0.0.1:5000/api/update_field_details
body:
    {
        "field_id": "94154805-8c01-4653-8592-feb960805ea8",
        "name": "Marcana Shefa",
        "utilities": {
            "Pool": 1,
            "Lights": 1,
            "Bathroom": 1,
            "Sport equipment": 1,
            "Free parking": 1
        }
    }

response:
    {
        "imageURL": "lib/images/samir_stadium.jpg",
        "latitude": "17.53.85",
        "location": "shefa-amr",
        "longitude": "-191.1373",
        "name": "shefa club",
        "sport_type": "tennis",
        "uid": "94154805-8c01-4653-8592-feb960805ea8",
        "utilities": {
            "Bathroom": 1,
            "Free parking": 0,
            "Lights": 0,
            "Pool": 0,
            "Sport equipment": 1
        }
    }

other response:
    {
        "message": "Field not found"
    }

other response:
    {
        "error": "Field ID must be a valid UUID"
    }
OR:
    {
        "error": "Field ID is required"
    }



api URL: http://127.0.0.1:5000/api/delete_field
body:
    {
        "field_id": "valid-field-uuid",
        "manager_id": "valid-manager-uuid"
    }

response:
    {
        "message": "Field deleted successfully"
    }

other response:
    {
        "message": "Field ID and Manager ID are required"
    }
OR:
    {
        "message": "Field ID and Manager ID must be valid UUIDs"
    }
OR:
    {
        "message": "Field does not belong to this manager"
    }
  
api_url: http://127.0.0.1:5000/api/get_fields_by_sport_type
body:
    {
    "sport_type": "football"
    }
response:
    [
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "37.23.55",
            "location": "adi",
            "longitude": "-122.0373",
            "name": "adi club",
            "sport_type": "Football",
            "uid": "df116407-9f58-448b-a541-1f66974b48f3",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        },
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "17.53.85",
            "location": "shefa-amr",
            "longitude": "-191.1373",
            "name": "shefa club",
            "sport_type": "Football",
            "uid": "1cade9b6-480c-4717-84ff-b33b0e8ab5b4",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        }
    ]

other response:
    {
        "message": "No fields found for the given sport type"
    }
OR:
    {
        "error": "Sport type parameter is required"
    }

api_url: http://127.0.0.1:5000/api/get_fields_by_manager_id
body:
    {
    "manager_id": "984622a0-ec0f-427a-b004-a0573b8933d3"
    }
response:
    [
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "37.23.55",
            "location": "adi",
            "longitude": "-122.0373",
            "name": "adi club",
            "sport_type": "tennis",
            "uid": "cf98fbe7-bf6c-4136-a7e3-b41dc7506571",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        },
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "37.23.55",
            "location": "adi",
            "longitude": "-122.0373",
            "name": "adi club",
            "sport_type": "Football",
            "uid": "df116407-9f58-448b-a541-1f66974b48f3",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        },
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "17.53.85",
            "location": "shefa-amr",
            "longitude": "-191.1373",
            "name": "shefa club",
            "sport_type": "Football",
            "uid": "1cade9b6-480c-4717-84ff-b33b0e8ab5b4",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        },
        {
            "imageURL": "lib/images/samir_stadium.jpg",
            "latitude": "17.53.85",
            "location": "shefa-amr",
            "longitude": "-191.1373",
            "name": "shefa club",
            "sport_type": "tennis",
            "uid": "94154805-8c01-4653-8592-feb960805ea8",
            "utilities": {
                "Bathroom": 1,
                "Free parking": 0,
                "Lights": 0,
                "Pool": 0,
                "Sport equipment": 1
            }
        }
    ]

other respone:
    {
        "message": "No fields found for the given Manager ID"
    }
OR:
    {
        "error": "Manager ID must be a valid UUID"
    }
OR:
    {
        "error": "Manager ID parameter is required"
    }


api URL: http://127.0.0.1:5000/api/add_rating
body:
    {
        "field_id": "0d4d41a4-105c-48ad-80a2-5c5e0e8f3f7f",
        "user_id": "ab40d55f-0b04-46a0-9225-02beca70ecfd",
        "rating": 4.5
    }
response:
    {
        "message": "Rating created successfully"
    }
OR:
    {
        "message": "Rating updated successfully"
    }

Other response:
    {
        "error": "User does not exist."
    }
OR:
    {
        "error": "Field does not exist."
    }
OR:
    {
        "error": "Field ID must be a valid UUID"
    }
OR:
    {
        "error": "User ID must be a valid UUID"
    }

api_url: http://127.0.0.1:5000/api/create_reservation
body:
    {
    "field_id": "25096a7b-4566-4f34-b45e-920e3d67cde9",
    "date": "20.09.2023",
    "interval_time": "15:00-17:00",
    "status": "pending",
    "du_date": "20.09.2023",
    "du_time": "18:00",
    "user_uuid": "c22424d8-909a-45a1-809a-6e06bbdc0aa8",
    "price": "50",
    "field_name": "samer",
    "location": "shefa-amr",
        "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg"
    }
response:
    {
        "message": "Reservation created successfully"
    }

api_url:http://127.0.0.1:5000/api/get_reservation
body:
    {
        "uuid": "d8856094-79d0-44fd-9819-01f6f1a7b982"
    }
response:
    [
        {
            "date": "20.09.2023",
            "du_date": "20.09.2023",
            "du_time": "17:00",
            "field_id": "171bc20e-7964-4045-90e8-cb3429455a05",
            "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg",
            "interval_time": "15:00-17:00",
            "location": "haifa",
            "name": "marcana",
            "price": 50,
            "status": "pending",
            "uid": "c21dd6af-3b40-40d0-9348-afeaf77de7a7",
            "user_uuid": "d8856094-79d0-44fd-9819-01f6f1a7b982"
        },
        {
            "date": "20.09.2023",
            "du_date": "20.09.2023",
            "du_time": "17:00",
            "field_id": "25096a7b-4566-4f34-b45e-920e3d67cde9",
            "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg",
            "interval_time": "15:00-17:00",
            "location": "haifa",
            "name": "marcana",
            "price": 50,
            "status": "pending",
            "uid": "0963245a-7856-4c09-b798-58288a026598",
            "user_uuid": "d8856094-79d0-44fd-9819-01f6f1a7b982"
        },
        {
            "date": "20.09.2023",
            "du_date": "20.09.2023",
            "du_time": "17:00",
            "field_id": "25096a7b-4566-4f34-b45e-920e3d67cde9",
            "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg",
            "interval_time": "15:00-17:00",
            "location": "shefa-amr",
            "name": "samer",
            "price": 50,
            "status": "pending",
            "uid": "ecb1512e-f714-4c35-abb4-26e26c465218",
            "user_uuid": "d8856094-79d0-44fd-9819-01f6f1a7b982"
        }
    ]

Other response:
    {
        "error": "User ID must be a valid UUID"
    }
OR:
    {
        "error": "User does not exist"
    }
OR:
    {
        "message": "No reservations found for the given user ID"
    }

api_url: http://127.0.0.1:5000/api/update_reservation_status
body:
    {
    "reservation_uuid": "c21dd6af-3b40-40d0-9348-afeaf77de7a7",
    "status": "Accepted"
    }
response:
    {
        "message": "Reservation status updated successfully"
    }

Other response:
    {
        "message": "Reservation not found or status update failed"
    }
OR:
    {   
        "error": "Status is required"
    }
OR:
    {
        'error': 'Reservation UUID must be a valid UUID'
    }
OR:
    {
        "error": "Reservation UUID is required"
    }

api_url:http://127.0.0.1:5000/api/get_reservations_by_manager
body:
    {
        "manager_id": "6d3c4dc5-0951-41b1-afc7-139cc019e1a1"
    }
response:
    [
        {
            "date": "28.09.2023",
            "du_date": "28.09.2023",
            "du_time": "15:00",
            "field_id": "cf98fbe7-bf6c-4136-a7e3-b41dc7506571",
            "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg",
            "interval_time": "14:00-15:00",
            "location": "haifa",
            "name": "marcana",
            "price": 50,
            "status": "pending",
            "uid": "a9f0b2b4-0855-4bd8-b23f-ebca3257e2bf",
            "user_uuid": "fc328116-cc1a-4c53-81f1-9db545c40d78"
        },
        {
            "date": "28.09.2023",
            "du_date": "28.09.2023",
            "du_time": "18:00",
            "field_id": "cf98fbe7-bf6c-4136-a7e3-b41dc7506571",
            "imageURL": "http://10.0.0.12/api/images/samir_stadium.jpg",
            "interval_time": "18:00-20:00",
            "location": "haifa",
            "name": "marcana",
            "price": 60,
            "status": "pending",
            "uid": "56318498-4673-41b2-a1b4-6ddc831df8ff",
            "user_uuid": "fc328116-cc1a-4c53-81f1-9db545c40d78"
        }
    ]

Other esponse:
    {
        "error": "Manager ID parameter is required"
    }
OR:
    {
        "error": "Manager ID must be a valid UUID"
    }
OR:
    {
        "message": "No reservations found for the given manager ID"
    }    

api URL:  http://127.0.0.1:5000/api/create_payment
body:
    {
        "carHolderID":"858888955",
        "cardNumber":"45698712365",
        "digitCode":"558",
        "month": "15",
        "name": "obied",
        "year": "2026",
        "userid": "fc328116-cc1a-4c53-81f1-9db545c40d78"
    }

response:
    {
        "message": "Payment created successfully"
    }

Other response:
    {
        "error": "A payment with this card number already exists"
    }
OR:
    {
        "error": "carHolderID is required"
    }
OR:
    {
        "error": "cardNumber is required"
    }
OR:
    {
        "error": "digitCode is required"
    }
OR:
    {
        "error": "month is required"
    }
OR:
    {
        "error": "year is required"
    }
OR:
    {
        "error": "name is required"
    }
OR:
    {
        "error": "User ID must be a valid UUID"
    }
     
api URL:  http://127.0.0.1:5000/api/get_payment_by_id
body:
    {
        "userid":"ab40d55f-0b04-46a0-9225-02beca70ecfd"
    }

    [
        {
            "cardNumber": "4325678914326545",
            "name": "obied"
        },
        {
            "cardNumber": "4123789654328877",
            "name": "obied"
        }
    ]

Other response:
    {
        "message": "No payments found for this user"
    }
OR:
    {
        "error": "User ID must be a valid UUID"
    }

api URL:http://127.0.0.1:5000/api/delete_payment
body:
    {
        "user_id": "fc328116-cc1a-4c53-81f1-9db545c40d78",
        "cardNumber":"412378976632845"
    }
response:
    {
        "message": "Payment deleted successfully"
    }
Other response:
    {
        "error": "Card not found"
    }
OR:
    {
        "error": "Card Number is required"
    }
OR:
    {
        "error": "User ID must be a valid UUID"
    }

"""