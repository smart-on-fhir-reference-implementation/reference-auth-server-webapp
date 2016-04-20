--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

SET AUTOCOMMIT FALSE;

START TRANSACTION;

--
-- Insert client information into the temporary tables. To add clients to the HSQL database, edit things here.
-- 

INSERT INTO client_details_TEMP (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection) VALUES
    ('client', 'secret', 'Test Client', false, null, 3600, 600, true);

--TODO: Curl script for these...
INSERT INTO client_scope_TEMP (owner_id, scope) VALUES
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'openid'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'profile'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'smart/orchestrate_launch'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'launch'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'launch/patient'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'launch/encounter'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'launch/other'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'user/Patient.read'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'user/*.*'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'user/*.read'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'patient/*.*'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'patient/*.read'),   
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'offline_access');


INSERT INTO client_redirect_uri_TEMP (owner_id, redirect_uri) VALUES
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'http://localhost/'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'http://localhost:8080/');
    
INSERT INTO client_grant_type_TEMP (owner_id, grant_type) VALUES
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'authorization_code'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'urn:ietf:params:oauth:grant_type:redelegate'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'implicit'),
    ((SELECT id from client_details_TEMP where client_id = 'client'), 'refresh_token');
    
-- Merge the temporary clients safely into the database. This is a two-step process to keep clients from being created on every startup with a persistent store.
--
--

MERGE INTO client_details 
  USING (SELECT client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection FROM client_details_TEMP) AS vals(client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection)
  ON vals.client_id = client_details.client_id
  WHEN NOT MATCHED THEN 
    INSERT (client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection) VALUES(client_id, client_secret, client_name, dynamically_registered, refresh_token_validity_seconds, access_token_validity_seconds, id_token_validity_seconds, allow_introspection);

MERGE INTO client_scope 
  USING (SELECT id, scope FROM client_scope_TEMP, client_details WHERE client_details.client_id = client_scope_TEMP.owner_id) AS vals(id, scope)
  ON vals.id = client_scope.owner_id AND vals.scope = client_scope.scope
  WHEN NOT MATCHED THEN 
    INSERT (owner_id, scope) values (vals.id, vals.scope);

MERGE INTO client_redirect_uri 
  USING (SELECT id, redirect_uri FROM client_redirect_uri_TEMP, client_details WHERE client_details.client_id = client_redirect_uri_TEMP.owner_id) AS vals(id, redirect_uri)
  ON vals.id = client_redirect_uri.owner_id AND vals.redirect_uri = client_redirect_uri.redirect_uri
  WHEN NOT MATCHED THEN 
    INSERT (owner_id, redirect_uri) values (vals.id, vals.redirect_uri);

MERGE INTO client_grant_type 
  USING (SELECT id, grant_type FROM client_grant_type_TEMP, client_details WHERE client_details.client_id = client_grant_type_TEMP.owner_id) AS vals(id, grant_type)
  ON vals.id = client_grant_type.owner_id AND vals.grant_type = client_grant_type.grant_type
  WHEN NOT MATCHED THEN 
    INSERT (owner_id, grant_type) values (vals.id, vals.grant_type);
    
-- 
-- Close the transaction and turn autocommit back on
-- 
    
COMMIT;

SET AUTOCOMMIT TRUE;

