/*
  # Fix Profiles Trigger and Create Missing Profiles

  1. Issue: The handle_new_user() trigger was not firing, leaving profiles table empty
  2. Solution:
     - Recreate the trigger with proper permissions
     - Populate existing auth users' profiles
     - Ensure trigger is properly enabled
*/

-- First, recreate the trigger function with proper permissions
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = 'public'
AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name', '')
    )
    ON CONFLICT (id) DO NOTHING;
    RETURN new;
END;
$$;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Populate existing auth users' profiles
INSERT INTO public.profiles (id, email, full_name)
SELECT 
    id,
    email,
    COALESCE(raw_user_meta_data ->> 'full_name', raw_user_meta_data ->> 'name', '')
FROM auth.users
ON CONFLICT (id) DO NOTHING;
