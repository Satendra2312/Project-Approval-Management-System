DELIMITER //

CREATE PROCEDURE sp_approve_project(IN project_id INT, IN admin_user_id INT)
BEGIN
    -- Check if the project exists and is pending
    IF EXISTS (SELECT 1 FROM projects WHERE id = project_id AND status = 'pending') THEN
        -- Update project status
        UPDATE projects SET status = 'approved' WHERE id = project_id;

        -- Log the approval action
        INSERT INTO audit_logs (user_id, action, auditable_id, auditable_type, timestamp)
        VALUES (admin_user_id, 'project_approved', project_id, 'App\\Models\\Project', NOW());

        -- Insert into approvals table
        INSERT INTO approvals (project_id, admin_id, status, created_at, updated_at)
        VALUES (project_id, admin_user_id, 'approved', NOW(), NOW());

        SELECT 'success' AS status;
    ELSE
        SELECT 'failure' AS status;
    END IF;
END //

DELIMITER ;