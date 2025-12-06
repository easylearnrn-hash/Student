-- Delete December 5-6 payments so they can be re-imported with correct dates
-- After running this, go to Payment-Records.html and click Gmail to re-fetch

DELETE FROM payments 
WHERE date >= '2025-12-05' 
  AND date <= '2025-12-06';

-- This will remove the wrongly-dated payments
-- Then in Payment-Records.html, click the Gmail button
-- The timezone fix will now save them with the correct December 5 date
