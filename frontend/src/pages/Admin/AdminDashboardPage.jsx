import React, { useState } from 'react';
import { Row, Col, Card, Table } from 'react-bootstrap';
import { FaUsers, FaFolder, FaCheckCircle, FaHourglassHalf, FaTimesCircle } from 'react-icons/fa';
import styles from './AdminDashboard.module.css';
import { useProjectData } from '../../hooks/useProjectdata';

const Dashboard = () => {
    const [sortConfig, setSortConfig] = useState({ key: 'name', direction: 'asc' });
    const [tableData, setTableData] = useState([
        { id: 1, name: 'John Doe', email: 'john@example.com', role: 'Admin', status: 'Active' },
        { id: 2, name: 'Jane Smith', email: 'jane@example.com', role: 'User', status: 'Inactive' },
        { id: 3, name: 'Bob Johnson', email: 'bob@example.com', role: 'Editor', status: 'Active' },
    ]);
    const allTableData = [...tableData];
    const { data: projectData, loading: projectLoading, error: projectError } = useProjectData();
    console.log('Dashboard Project', projectData);
    const sortTable = (key) => {
        const direction = sortConfig.key === key && sortConfig.direction === 'asc' ? 'desc' : 'asc';
        setSortConfig({ key, direction });
        const sortedData = [...allTableData].sort((a, b) => {
            if (a[key] < b[key]) return direction === 'asc' ? -1 : 1;
            if (a[key] > b[key]) return direction === 'asc' ? 1 : -1;
            return 0;
        });
        setTableData(sortedData);
    };

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
                        icon: <FaFolder />, title: 'Total Projects', value: projectData.data?.total_projects || 'N/A', color: '#64748b'
                    },
                    {
                        icon: <FaCheckCircle />, title: 'Total Approved Projects', value: projectData.data?.
                            total_approval_projects
                            || 'N/A', color: '#28a745'
                    },
                    {
                        icon: <FaHourglassHalf />, title: 'Total Pending Projects', value: projectData.data?.
                            total_pending_projects
                            || 'N/A', color: '#ffc107'
                    },
                    {
                        icon: <FaTimesCircle />, title: 'Total Rejected Projects', value: projectData.data?.
                            total_reject_projects
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

            <Row className="mb-4">
                <Col md={12}>
                    <Card className={`${styles.card} shadow-sm border-0`}>
                        <Card.Body>
                            <Card.Title className={styles.cardTitle}>User Management</Card.Title>
                            <Table responsive hover className={styles.table}>
                                <thead>
                                    <tr>
                                        {['name', 'email', 'role', 'status'].map((key) => (
                                            <th key={key} onClick={() => sortTable(key)} className={styles.tableHeader}>
                                                {key.charAt(0).toUpperCase() + key.slice(1)}
                                                {sortConfig.key === key && (
                                                    <i className={`bi bi-caret-${sortConfig.direction === 'asc' ? 'up' : 'down'}-fill ms-1`}></i>
                                                )}
                                            </th>
                                        ))}
                                    </tr>
                                </thead>
                                <tbody>
                                    {tableData.map((row) => (
                                        <tr key={row.id}>
                                            <td>{row.name}</td>
                                            <td>{row.email}</td>
                                            <td>{row.role}</td>
                                            <td>
                                                <span className={`${styles.badge} ${row.status === 'Active' ? styles.badgeSuccess : styles.badgeWarning}`}>
                                                    {row.status}
                                                </span>
                                            </td>
                                        </tr>
                                    ))}
                                </tbody>
                            </Table>
                        </Card.Body>
                    </Card>
                </Col>
            </Row>
        </div>
    );
};

export default Dashboard;

