-- Permite que cuidadores ativos visualizem os pets a que estao atribuidos.
-- Necessario para o CaregiverDashboardPage fazer join caregivers->pets.

alter table pets enable row level security;

drop policy if exists "Caregivers can view assigned pets" on pets;
create policy "Caregivers can view assigned pets" on pets
  for select
  using (
    auth.uid() in (
      select caregiver_id
      from caregivers
      where pet_id = pets.id and status = 'active'
    )
  );
