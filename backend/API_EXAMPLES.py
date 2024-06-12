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

    another response:
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
"""