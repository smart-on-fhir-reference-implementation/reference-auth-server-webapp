--
-- Turn off autocommit and start a transaction so that we can use the temp tables
--

SET AUTOCOMMIT FALSE;

START TRANSACTION;

--
-- Insert scope information into the temporary tables.
-- 

INSERT INTO system_scope_TEMP (scope, description, icon, default_scope, structured, structured_param_description) VALUES
  ('openid', 'log in using your identity', 'user', true, false, null),
  ('profile', 'basic profile information', 'list-alt', true, false, null),
  ('smart/orchestrate_launch', 'Orchestrate a launch with EHR context', 'user', false, false, null),
  ('launch', 'Launch with an existing context', 'user', false, true, 'Launch from existing context'),
  ('launch/patient', 'Launch with patient context', 'user', false, true, 'Launch patient'),
  ('launch/encounter', 'Launch with encounter context', 'user', false, true, 'Launch encounter'),
  ('launch/resource', 'Launch with resource context', 'user', false, true, 'Launch resource'),
  ('launch/other', 'Launch with other context', 'user', false, true, 'Launch other'), 
  ('user/Patient.read', 'all FHIR permissions for user', 'user', false, false, null), 
  ('user/*.read', 'Read all FHIR data that you can access', 'user', false, false, null), 
  ('user/*.*', 'All FHIR permissions for data that you can access', 'user', false, false, null), 
  ('patient/*.read', 'Read all FHIR data for a single patient record', 'user', false, false, null), 
  ('patient/*.*', 'All FHIR permissions for a single patient record', 'user', false, false, null), 
  ('offline_access', 'offline access', 'time', true, false, null);

--
-- Merge the temporary scopes safely into the database. This is a two-step process to keep scopes from being created on every startup with a persistent store.
--

MERGE INTO system_scope
  USING (SELECT scope, description, icon, default_scope, structured, structured_param_description FROM system_scope_TEMP) AS vals(scope, description, icon, default_scope, structured, structured_param_description)
  ON vals.scope = system_scope.scope
  WHEN NOT MATCHED THEN
    INSERT (scope, description, icon, default_scope, structured, structured_param_description) VALUES(vals.scope, vals.description, vals.icon, vals.default_scope, vals.structured, vals.structured_param_description);

COMMIT;

SET AUTOCOMMIT TRUE;
