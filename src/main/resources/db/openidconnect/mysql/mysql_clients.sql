START TRANSACTION;

INSERT INTO client_details (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection) VALUES
    ('client', 'secret', 'Test Client', false, null, 3600, 600, true);

--TODO: Curl script for these...
INSERT INTO client_scope (owner_id, scope) VALUES
    ((SELECT id from client_details where client_id = 'client'), 'openid'),
    ((SELECT id from client_details where client_id = 'client'), 'profile'),
    ((SELECT id from client_details where client_id = 'client'), 'smart/orchestrate_launch'),
    ((SELECT id from client_details where client_id = 'client'), 'launch'),
    ((SELECT id from client_details where client_id = 'client'), 'launch/patient'),
    ((SELECT id from client_details where client_id = 'client'), 'launch/encounter'),
    ((SELECT id from client_details where client_id = 'client'), 'launch/other'),
    ((SELECT id from client_details where client_id = 'client'), 'user/Patient.read'),
    ((SELECT id from client_details where client_id = 'client'), 'user/*.*'),
    ((SELECT id from client_details where client_id = 'client'), 'user/*.read'),
    ((SELECT id from client_details where client_id = 'client'), 'patient/*.*'),
    ((SELECT id from client_details where client_id = 'client'), 'patient/*.read'),
    ((SELECT id from client_details where client_id = 'client'), 'offline_access');


INSERT INTO client_redirect_uri (owner_id, redirect_uri) VALUES
    ((SELECT id from client_details where client_id = 'client'), 'http://localhost/'),
    ((SELECT id from client_details where client_id = 'client'), 'http://localhost:8080/');

INSERT INTO client_grant_type (owner_id, grant_type) VALUES
    ((SELECT id from client_details where client_id = 'client'), 'authorization_code'),
    ((SELECT id from client_details where client_id = 'client'), 'urn:ietf:params:oauth:grant_type:redelegate'),
    ((SELECT id from client_details where client_id = 'client'), 'implicit'),
    ((SELECT id from client_details where client_id = 'client'), 'refresh_token');

COMMIT;
