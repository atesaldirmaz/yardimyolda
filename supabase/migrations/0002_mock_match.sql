-- Mock Provider Table and Auto-Matching Trigger
-- This migration creates mock providers and automatically matches service requests after 5 seconds

-- Create mock_providers table
create table if not exists mock_providers(
  id uuid primary key default gen_random_uuid(),
  name text not null,
  lat double precision not null,
  lng double precision not null,
  created_at timestamptz default now()
);

-- Insert at least one mock provider (Istanbul coordinates)
insert into mock_providers(name, lat, lng)
select 'Demo Provider', 41.083, 29.012
where not exists (select 1 from mock_providers);

-- Function to automatically match service requests after 5 seconds
-- This simulates finding a nearby provider
create or replace function match_after_insert()
returns trigger as $$
begin
  -- Run async task to match after 5 seconds
  perform pg_sleep(5);
  
  -- Update the service request to matched status
  update service_requests
    set status = 'matched',
        provider_id = (select id from mock_providers order by random() limit 1),
        updated_at = now()
  where id = NEW.id;
  
  return NEW;
end;
$$ language plpgsql;

-- Drop existing trigger if it exists
drop trigger if exists trg_match_after_insert on service_requests;

-- Create trigger to automatically match service requests after insert
create trigger trg_match_after_insert
after insert on service_requests
for each row execute procedure match_after_insert();

-- Enable realtime for service_requests table
alter publication supabase_realtime add table service_requests;

-- Comments for documentation
comment on table mock_providers is 'Mock providers table for development/testing purposes';
comment on function match_after_insert() is 'Automatically matches service requests with mock providers after 5 seconds';
comment on trigger trg_match_after_insert on service_requests is 'Trigger to simulate provider matching after service request creation';
