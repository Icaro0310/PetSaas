-- 0014_pets_weight_check.sql
-- weight_kg e numeric(5,2) (max 999,99). Sem constraint, valores grandes
-- rebentam com 22003 numeric field overflow em vez de erro claro.
-- Validacao no cliente existe, mas o check protege qualquer insercao.

alter table pets
  drop constraint if exists pets_weight_kg_range;

alter table pets
  add constraint pets_weight_kg_range
  check (weight_kg is null or (weight_kg > 0 and weight_kg < 1000));
