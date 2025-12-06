-- First, let's see what student names we have that are close to the unlinked payments
SELECT id, name, email, aliases
FROM students
WHERE 
  name ILIKE '%Mari%Poghosyan%' OR
  name ILIKE '%Poghosyan%Mari%' OR
  name ILIKE '%Ani%Sahakyan%' OR
  name ILIKE '%Sahakyan%Ani%'
ORDER BY name;
