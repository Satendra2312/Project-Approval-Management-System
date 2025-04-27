import React from 'react';
import { Row, Col, Card } from 'react-bootstrap';
import { FaUsers, FaFolder, FaCheckCircle, FaHourglassHalf, FaTimesCircle } from 'react-icons/fa';
import styles from './AdminDashboard.module.css';
import { useProjectData } from '../../hooks/useProjectData';

const Dashboard = () => {
    const { data: projectData, loading: projectLoading, error: projectError } = useProjectData();
    console.log('Dashboard Project', projectData);


    if (projectLoading) {
        return <div className="text-center py-5">Loading project data...</div>;
    }

    if (projectError) {
        return <div className="text-danger py-5">Error loading project data: {projectError}</div>;
    }

    return (
        <div className={styles.dashboard}>
            <h2 className={styles.title}>Dashboard Overview</h2>

            <Row xs={1} md={2} lg={4} className="g-4 mb-4">
                {[
                    {
                        icon: <FaFolder />, title: 'Total Projects', value: projectData.totals?.all || 'N/A', color: '#64748b'
                    },
                    {
                        icon: <FaCheckCircle />, title: 'Total Approved Projects', value: projectData.totals?.
                            approved
                            || 'N/A', color: '#28a745'
                    },
                    {
                        icon: <FaHourglassHalf />, title: 'Total Pending Projects', value: projectData.totals?.
                            pending
                            || 'N/A', color: '#ffc107'
                    },
                    {
                        icon: <FaTimesCircle />, title: 'Total Rejected Projects', value: projectData.totals?.
                            rejected
                            || 'N/A', color: '#dc3545'
                    },
                ].map((metric, index) => (
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

export default Dashboard;

