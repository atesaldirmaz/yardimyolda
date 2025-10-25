-- Yardım Yolda - Initial Database Schema
-- Created: 2025-10-22
-- Description: Creates tables for user profiles, service requests, and ratings with RLS policies

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- USER PROFILES TABLE
-- ============================================================================
-- Stores additional user information beyond auth.users
-- Links to Supabase Auth via user_id (UUID)

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('customer', 'provider', 'admin')),
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT,
    profile_picture_url TEXT,
    
    -- Provider-specific fields (nullable for customers)
    vehicle_type TEXT CHECK (vehicle_type IS NULL OR vehicle_type IN ('tow_truck', 'mobile_mechanic', 'fuel_delivery', 'tire_service')),
    license_plate TEXT,
    is_approved BOOLEAN DEFAULT false, -- Requires admin approval for providers
    is_available BOOLEAN DEFAULT false, -- Provider availability status
    
    -- Location for providers (last known location)
    last_known_lat DOUBLE PRECISION,
    last_known_lng DOUBLE PRECISION,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT valid_provider_fields CHECK (
        (role = 'provider' AND vehicle_type IS NOT NULL AND license_plate IS NOT NULL) OR
        (role != 'provider' AND vehicle_type IS NULL AND license_plate IS NULL)
    )
);

-- Create index for efficient queries
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_is_approved ON public.user_profiles(is_approved) WHERE role = 'provider';
CREATE INDEX idx_user_profiles_is_available ON public.user_profiles(is_available) WHERE role = 'provider';
CREATE INDEX idx_user_profiles_location ON public.user_profiles(last_known_lat, last_known_lng) WHERE role = 'provider';

-- ============================================================================
-- SERVICE REQUESTS TABLE
-- ============================================================================
-- Stores service requests from customers to providers

CREATE TABLE IF NOT EXISTS public.service_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- User references
    customer_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    
    -- Request status
    status TEXT NOT NULL DEFAULT 'pending' CHECK (
        status IN ('pending', 'quoted', 'accepted', 'in_progress', 'completed', 'cancelled', 'rejected')
    ),
    
    -- Service details
    service_type TEXT NOT NULL CHECK (
        service_type IN ('towing', 'battery_jump', 'tire_change', 'fuel_delivery', 'lockout', 'mechanical_repair')
    ),
    description TEXT,
    
    -- Customer location (at time of request)
    customer_lat DOUBLE PRECISION NOT NULL,
    customer_lng DOUBLE PRECISION NOT NULL,
    customer_address TEXT,
    
    -- Destination (for towing)
    destination_lat DOUBLE PRECISION,
    destination_lng DOUBLE PRECISION,
    destination_address TEXT,
    
    -- Pricing
    quoted_price DECIMAL(10, 2),
    final_price DECIMAL(10, 2),
    
    -- Photos (stored as array of URLs)
    photo_urls TEXT[],
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ
);

-- Create indexes for efficient queries
CREATE INDEX idx_service_requests_customer_id ON public.service_requests(customer_id);
CREATE INDEX idx_service_requests_provider_id ON public.service_requests(provider_id);
CREATE INDEX idx_service_requests_status ON public.service_requests(status);
CREATE INDEX idx_service_requests_created_at ON public.service_requests(created_at DESC);
CREATE INDEX idx_service_requests_location ON public.service_requests(customer_lat, customer_lng);

-- ============================================================================
-- RATINGS TABLE
-- ============================================================================
-- Stores ratings and reviews for completed service requests

CREATE TABLE IF NOT EXISTS public.ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- References
    request_id UUID NOT NULL UNIQUE REFERENCES public.service_requests(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    provider_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    
    -- Rating details
    stars INTEGER NOT NULL CHECK (stars >= 1 AND stars <= 5),
    comment TEXT,
    
    -- Timestamp
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for efficient queries
CREATE INDEX idx_ratings_provider_id ON public.ratings(provider_id);
CREATE INDEX idx_ratings_customer_id ON public.ratings(customer_id);
CREATE INDEX idx_ratings_request_id ON public.ratings(request_id);
CREATE INDEX idx_ratings_created_at ON public.ratings(created_at DESC);

-- ============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ratings ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- USER_PROFILES POLICIES
-- ----------------------------------------------------------------------------

-- Users can view their own profile
CREATE POLICY "Users can view own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Customers can view approved and available providers
CREATE POLICY "Customers can view approved providers"
    ON public.user_profiles FOR SELECT
    USING (
        role = 'provider' 
        AND is_approved = true 
        AND is_available = true
    );

-- Admins can view all profiles (will be implemented via service role key)

-- ----------------------------------------------------------------------------
-- SERVICE_REQUESTS POLICIES
-- ----------------------------------------------------------------------------

-- Customers can view their own requests
CREATE POLICY "Customers can view own requests"
    ON public.service_requests FOR SELECT
    USING (
        customer_id = auth.uid()
    );

-- Providers can view requests assigned to them or pending requests nearby
CREATE POLICY "Providers can view assigned or pending requests"
    ON public.service_requests FOR SELECT
    USING (
        provider_id = auth.uid() 
        OR (
            status = 'pending' 
            AND EXISTS (
                SELECT 1 FROM public.user_profiles 
                WHERE id = auth.uid() 
                AND role = 'provider' 
                AND is_approved = true 
                AND is_available = true
            )
        )
    );

-- Customers can create service requests
CREATE POLICY "Customers can create requests"
    ON public.service_requests FOR INSERT
    WITH CHECK (
        customer_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() 
            AND role = 'customer'
        )
    );

-- Customers can update their own pending requests
CREATE POLICY "Customers can update own pending requests"
    ON public.service_requests FOR UPDATE
    USING (
        customer_id = auth.uid() 
        AND status IN ('pending', 'quoted')
    );

-- Providers can update requests assigned to them
CREATE POLICY "Providers can update assigned requests"
    ON public.service_requests FOR UPDATE
    USING (
        provider_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() 
            AND role = 'provider' 
            AND is_approved = true
        )
    );

-- ----------------------------------------------------------------------------
-- RATINGS POLICIES
-- ----------------------------------------------------------------------------

-- Customers can view ratings they created
CREATE POLICY "Customers can view own ratings"
    ON public.ratings FOR SELECT
    USING (customer_id = auth.uid());

-- Providers can view ratings about them
CREATE POLICY "Providers can view ratings about them"
    ON public.ratings FOR SELECT
    USING (provider_id = auth.uid());

-- Anyone can view ratings for providers (public rating display)
CREATE POLICY "Anyone can view provider ratings"
    ON public.ratings FOR SELECT
    USING (true);

-- Customers can create ratings for completed requests
CREATE POLICY "Customers can create ratings"
    ON public.ratings FOR INSERT
    WITH CHECK (
        customer_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM public.service_requests 
            WHERE id = request_id 
            AND customer_id = auth.uid() 
            AND status = 'completed'
            AND provider_id IS NOT NULL
        )
    );

-- ============================================================================
-- FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for user_profiles
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for service_requests
CREATE TRIGGER update_service_requests_updated_at
    BEFORE UPDATE ON public.service_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate provider average rating
CREATE OR REPLACE FUNCTION get_provider_average_rating(provider_uuid UUID)
RETURNS DECIMAL AS $$
DECLARE
    avg_rating DECIMAL;
BEGIN
    SELECT AVG(stars) INTO avg_rating
    FROM public.ratings
    WHERE provider_id = provider_uuid;
    
    RETURN COALESCE(avg_rating, 0);
END;
$$ LANGUAGE plpgsql;

-- Function to count provider completed requests
CREATE OR REPLACE FUNCTION get_provider_completed_count(provider_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
    completed_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO completed_count
    FROM public.service_requests
    WHERE provider_id = provider_uuid
    AND status = 'completed';
    
    RETURN COALESCE(completed_count, 0);
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- INITIAL DATA (Optional)
-- ============================================================================

-- You can add initial admin users or test data here if needed
-- Example:
-- INSERT INTO public.user_profiles (id, role, name, phone, email)
-- VALUES ('uuid-here', 'admin', 'Admin User', '+905551234567', 'admin@yardimyolda.com');

-- ============================================================================
-- NOTES
-- ============================================================================
-- 
-- 1. Make sure to create a Supabase project first
-- 2. Copy the SUPABASE_URL and SUPABASE_ANON_KEY to your .env file
-- 3. Run this migration using Supabase CLI:
--    supabase db push
-- 4. Or apply directly in Supabase Dashboard > SQL Editor
-- 5. For provider approval, use Supabase Dashboard or create an admin panel
-- 6. Consider adding indexes for geospatial queries if using PostGIS
-- 7. FCM tokens can be stored in user_profiles if needed later
--
-- ============================================================================
