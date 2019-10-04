-- Find Missing Links
--
-- Returns stable ids and comment ids for comments that
-- reference a gene id that is not present in the
-- apidbtuning.geneid table.
WITH
  comments AS (
    SELECT
      cl.comment_id
    , cl.comment_stable_id
    , cl.stable_id
    FROM
      userlogins5.commentstableid@rm38488.login_comment cl
      INNER JOIN userlogins5.comments@rm38488.login_comment co
        ON cl.comment_id = co.comment_id
    WHERE
      co.project_name = ?
  )
  , filtered AS (
    SELECT
      stable_id
    FROM
      comments
    MINUS
    SELECT
      id AS stable_id
    FROM
      apidbtuning.geneid
  )
SELECT
  co.*
FROM
  comments co
WHERE
  EXISTS (SELECT 1 FROM filtered WHERE stable_id = co.stable_id)
;
