import React from 'react';
import { Row, Col, Card } from 'react-bootstrap';
import { FaFolder, FaCheckCircle, FaHourglassHalf, FaTimesCircle, FaUser } from 'react-icons/fa';
import styles from './UserDashboard.module.css';
import { useProjectData } from '../../hooks/useProjectData';
import { useAuth } from '../../providers/AuthProvider';

const UserDashboardPage = () => {
    const { user } = useAuth();
    const { data: projectData, loading: projectLoading, error: projectError } = useProjectData();
    console.log('Dashboard Project', projectData);

    if (projectLoading) {
        return <div className="text-center py-5">Loading project data...</div>;
    }

    if (projectError) {
        return <div className="text-danger py-5">Error loading project data: {projectError}</div>;
    }

    // Determine if the user is an admin
    const isAdmin = user?.role === 'admin';

    let metrics;
    if (isAdmin) {
        metrics = [
            { icon: <FaFolder />, title: 'Total Projects', value: projectData.data.totals?.all || 'N/A', color: '#64748b' },
            { icon: <FaCheckCircle />, title: 'Total Approved Projects', value: projectData.data.totals?.approved || 'N/A', color: '#28a745' },
            { icon: <FaHourglassHalf />, title: 'Total Pending Projects', value: projectData.data.totals?.pending || 'N/A', color: '#ffc107' },
            { icon: <FaTimesCircle />, title: 'Total Rejected Projects', value: projectData.data.totals?.rejected || 'N/A', color: '#dc3545' },
        ];
    } else {
        //Show only projects submitted by the logged-in user.
        const userProjects = projectData.projects.filter(project => project?.submittedBy?.id === user?.id);
        const userApproved = userProjects.filter(p => p.status === 'approved').length;
        const userPending = userProjects.filter(p => p.status === 'pending').length;
        const userRejected = userProjects.filter(p => p.status === 'rejected').length;

        metrics = [
            { icon: <FaFolder />, title: 'My Projects', value: userProjects.length || 0, color: '#64748b' },
            { icon: <FaCheckCircle />, title: 'My Approved Projects', value: userApproved || 0, color: '#28a745' },
            { icon: <FaHourglassHalf />, title: 'My Pending Projects', value: userPending || 0, color: '#ffc107' },
            { icon: <FaTimesCircle />, title: 'My Rejected Projects', value: userRejected || 0, color: '#dc3545' },
        ];
    }

    return (
        <div className={styles.dashboard}>
            <h2 className={styles.title}>Dashboard Overview</h2>

            <Row xs={1} md={2} lg={4} className="g-4 mb-4">
                {metrics.map((metric, index) => (
                    <Col key={index}>
                        <Card className={`${styles.card} shadow-sm border-0`}>
                            <Card.Body className="text-center">
                                <div className={styles.icon} style={{ color: metric.color }}>
                                    {metric.icon}
                                </div>
                                <Card.Title className={styles.cardTitle}>{metric.title}</Card.Title>
                                <Card.Text className={styles.cardValue}>{metric.value}</Card.Text>
                            </Card.Body>
                        </Card>
                    </Col>
                ))}
            </Row>
        </div>
    );
};

export default UserDashboardPage;
