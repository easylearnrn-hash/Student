-- Question count per topic in one small response (the topic picker used to download every topic_id row).
-- Read-only, runs with the caller's own permissions, so Row Level Security applies exactly as for a normal select.
create or replace function public.get_topic_question_counts()
returns table (topic_id uuid, question_count bigint)
language sql
stable
security invoker
set search_path = public
as $$
  select q.topic_id, count(*)::bigint
  from public.test_questions q
  where q.is_active = true and q.topic_id is not null
  group by q.topic_id;
$$;

grant execute on function public.get_topic_question_counts() to anon, authenticated;
