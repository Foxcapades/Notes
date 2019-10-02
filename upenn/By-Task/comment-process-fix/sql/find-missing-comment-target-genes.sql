-- Find Deletable Links
WITH
  -- Comment link data for comments which have related
  -- stable id links and belong to the specified project
  --
  -- Returns 3942 rows
  comments AS (
    SELECT
      a.comment_id
    , a.stable_id
    , a.comment_stable_id
    FROM
      userlogins5.commentstableid@rm38488.login_comment a
      INNER JOIN userlogins5.comments@rm38488.login_comment b
        ON a.comment_id = b.comment_id
    WHERE
      b.project_name = 'PlasmoDB'
  )

  -- Comment data joined to gene data based on the linked
  -- gene id matching an id in the app db geneid table.
  --
  -- NOTE: This query will exclude comment-to-gene links
  --   that have an invalid gene id.
  --
  -- Returns 3867 rows (less because excludes invalid ids)
  , cross_join AS (
    SELECT
      co.comment_id
    , co.comment_stable_id
    , gi.database_name
    , gi.gene
    FROM
      comments co
      INNER JOIN apidbtuning.geneid gi
        ON co.stable_id = gi.id
  )

  -- Select the most recent link per gene per comment to
  -- exclude from the link deletion list.
  --
  -- Returns 3494 rows (less because excludes duplicate links)
  , most_recent AS (
    SELECT
      comment_id
    , gene
    , max(comment_stable_id) AS comment_stable_id
    FROM
      cross_join
    GROUP BY
      comment_id
    , gene
  )

SELECT
  comment_stable_id
FROM
  cross_join
MINUS
SELECT
  comment_stable_id
FROM
  most_recent
;