DROP INDEX IF EXISTS idx_chats_user_updated;

CREATE INDEX idx_chats_user_updated_id
ON chats (user_id, updated_at DESC, id DESC)
INCLUDE (title);