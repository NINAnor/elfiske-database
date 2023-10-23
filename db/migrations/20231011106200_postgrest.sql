-- migrate:up

-- Automatic Schema Cache Reloading
-- You can do automatic schema cache reloading in a pure SQL way and forget about stale schema cache errors with an event trigger and NOTIFY.

-- see: https://postgrest.org/en/v8.0/schema_cache.html#automatic-schema-cache-reloading

-- Create an event trigger function
CREATE OR REPLACE FUNCTION public.pgrst_watch() RETURNS event_trigger
  LANGUAGE plpgsql
  AS $$
BEGIN
  NOTIFY pgrst, 'reload schema';
END;
$$;

-- This event trigger will fire after every ddl_command_end event
CREATE EVENT TRIGGER pgrst_watch
  ON ddl_command_end
  EXECUTE PROCEDURE public.pgrst_watch();

-- migrate:down
DROP EVENT TRIGGER pgrst_watch
