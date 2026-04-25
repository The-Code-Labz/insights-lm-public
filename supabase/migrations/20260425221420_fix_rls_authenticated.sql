/*
  # Fix RLS Policies for Authenticated Users

  1. Issue: RLS policies were set to public role but need authenticated role
  2. Solution: Recreate policies to properly allow authenticated users to insert
*/

-- Drop and recreate the INSERT policy for notebooks
DROP POLICY IF EXISTS "Users can create their own notebooks" ON public.notebooks;
CREATE POLICY "Users can create their own notebooks"
    ON public.notebooks FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Also verify SELECT policy
DROP POLICY IF EXISTS "Users can view their own notebooks" ON public.notebooks;
CREATE POLICY "Users can view their own notebooks"
    ON public.notebooks FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- Verify UPDATE policy
DROP POLICY IF EXISTS "Users can update their own notebooks" ON public.notebooks;
CREATE POLICY "Users can update their own notebooks"
    ON public.notebooks FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Verify DELETE policy
DROP POLICY IF EXISTS "Users can delete their own notebooks" ON public.notebooks;
CREATE POLICY "Users can delete their own notebooks"
    ON public.notebooks FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
