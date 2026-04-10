const fs = require('fs');

async function run() {
  const token = 'sbp_921285b3ce7187050c821339acb940d99a717a78';
  const ref = 'zlvnxvrzotamhpezqedr';
  
  let sql = `DELETE FROM test_questions WHERE category IN ('EKG', 'Heart Failure');`;
  
  const res = await fetch(`https://api.supabase.com/v1/projects/${ref}/database/query`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ query: sql })
  });
  
  const data = await res.text();
  console.log(res.status, data);
}
run();
