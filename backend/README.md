DELIMITER //

CREATE PROCEDURE sp_approve_project (
IN project_id INT,
IN approver_id INT
)
BEGIN
-- Check if the project exists
IF NOT EXISTS (SELECT 1 FROM projects WHERE id = project_id) THEN
SELECT 'error' AS status, 'Project not found.' AS message;
ELSE
-- Check if the project is already approved
IF (SELECT status FROM projects WHERE id = project_id) = 'approved' THEN
SELECT 'success' AS status, 'Project is already approved.' AS message;
ELSE
-- Update the project status to 'approved'
UPDATE projects SET status = 'approved' WHERE id = project_id;

            SELECT 'success' AS status, 'Project approved successfully.' AS message;
        END IF;
    END IF;

END //

DELIMITER ;

<!-- Maisending for use  -->

Queued Mail Sending Sending Use :
run php artisan queue:work cmd and then work
