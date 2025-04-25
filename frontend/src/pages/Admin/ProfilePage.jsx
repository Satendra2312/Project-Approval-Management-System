import React from "react";
import { Card, Button, Container } from "react-bootstrap";
import { FaUserCircle } from "react-icons/fa";
import styles from "./ProfilePage.module.css";
import { useAuth } from "../../providers/AuthProvider";

const ProfilePage = () => {
    const { user } = useAuth();

    return (
        <Container className={styles.profileContainer}>
            <Card className={`${styles.profileCard} shadow`}>
                <Card.Body className="text-center">
                    <FaUserCircle className={styles.profileIcon} />
                    <h3>{user?.name || "Guest"}</h3>
                    <p className="text-muted">{user?.role || "Unknown Role"}</p>
                    <hr />
                    <Button variant="primary" href="/settings">Edit Profile</Button>
                </Card.Body>
            </Card>
        </Container>
    );
};

export default ProfilePage;
