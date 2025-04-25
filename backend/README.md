DELIMITER //

CREATE PROCEDURE sp_update_project_status(
IN project_id INT,
IN admin_user_id INT,
IN new_status ENUM('approved', 'rejected', 'pending'),
IN rejection_reason TEXT
)
BEGIN
DECLARE current_status VARCHAR(20);

    -- Start transaction
    START TRANSACTION;

    -- Fetch current status
    SELECT status INTO current_status FROM projects WHERE id = project_id;

    -- Validate project existence
    IF current_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Project not found';
        ROLLBACK;
    ELSE
        -- Prevent unnecessary updates
        IF current_status = new_status THEN
            SELECT 'success' AS status, CONCAT('Project is already ', new_status) AS message;
        ELSE
            -- Handle transitions based on current status
            CASE
                WHEN current_status = 'pending' THEN
                    UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;

                    IF new_status = 'approved' THEN
                        INSERT INTO approvals (project_id, admin_id, status, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'approved', NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'approved', updated_at = NOW();
                    ELSEIF new_status = 'rejected' THEN
                        INSERT INTO approvals (project_id, admin_id, status, rejection_reason, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'rejected', rejection_reason, NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'rejected', rejection_reason = rejection_reason, updated_at = NOW();
                    END IF;

                WHEN current_status = 'approved' THEN
                    IF new_status = 'rejected' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;

                        INSERT INTO approvals (project_id, admin_id, status, rejection_reason, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'rejected', rejection_reason, NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'rejected', rejection_reason = rejection_reason, updated_at = NOW();
                    ELSEIF new_status = 'pending' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        DELETE FROM approvals WHERE project_id = project_id;
                    END IF;

                WHEN current_status = 'rejected' THEN
                    IF new_status = 'approved' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;

                        INSERT INTO approvals (project_id, admin_id, status, created_at, updated_at)
                        VALUES (project_id, admin_user_id, 'approved', NOW(), NOW())
                        ON DUPLICATE KEY UPDATE status = 'approved', updated_at = NOW();
                    ELSEIF new_status = 'pending' THEN
                        UPDATE projects SET status = new_status, updated_at = NOW() WHERE id = project_id;
                        DELETE FROM approvals WHERE project_id = project_id;
                    END IF;
            END CASE;

            -- Log status update
            INSERT INTO audit_logs (user_id, action, auditable_id, auditable_type, timestamp)
            VALUES (admin_user_id, CONCAT('project_', new_status), project_id, 'App\\Models\\Project', NOW());

            -- Commit changes
            COMMIT;
            SELECT 'success' AS status, CONCAT('Project status updated to ', new_status) AS message;
        END IF;
    END IF;

END //

DELIMITER ;
