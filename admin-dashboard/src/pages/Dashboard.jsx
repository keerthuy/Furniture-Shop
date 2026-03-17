import { useState, useEffect } from 'react';
import api from '../services/api';
import { FiPackage, FiShoppingCart, FiUsers, FiDollarSign, FiTrendingUp } from 'react-icons/fi';

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const res = await api.get('/admin/stats');
      setStats(res.data.data);
    } catch (err) {
      console.error('Failed to fetch stats:', err);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div className="loading-spinner">Loading...</div>;

  const statusColors = {
    Pending: '#C08552',
    Processing: '#8C5A3C',
    Shipped: '#3498db',
    Delivered: '#27ae60',
    Cancelled: '#e74c3c',
  };

  return (
    <div className="dashboard-page">
      <h1 className="page-title">Dashboard</h1>

      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#C08552' }}><FiPackage /></div>
          <div className="stat-info">
            <span className="stat-value">{stats?.totalProducts || 0}</span>
            <span className="stat-label">Products</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#8C5A3C' }}><FiShoppingCart /></div>
          <div className="stat-info">
            <span className="stat-value">{stats?.totalOrders || 0}</span>
            <span className="stat-label">Total Orders</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#4B2E2B' }}><FiUsers /></div>
          <div className="stat-info">
            <span className="stat-value">{stats?.totalCustomers || 0}</span>
            <span className="stat-label">Customers</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#27ae60' }}><FiDollarSign /></div>
          <div className="stat-info">
            <span className="stat-value">Rs.{stats?.totalRevenue?.toLocaleString() || 0}</span>
            <span className="stat-label">Revenue</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon" style={{ background: '#3498db' }}><FiTrendingUp /></div>
          <div className="stat-info">
            <span className="stat-value">{stats?.ordersToday || 0}</span>
            <span className="stat-label">Orders Today</span>
          </div>
        </div>
      </div>

      {stats?.ordersByStatus && stats.ordersByStatus.length > 0 && (
        <div className="card">
          <h2 className="card-title">Orders by Status</h2>
          <div className="status-badges">
            {stats.ordersByStatus.map((s) => (
              <span key={s._id} className="status-badge" style={{ background: statusColors[s._id] || '#999' }}>
                {s._id}: {s.count}
              </span>
            ))}
          </div>
        </div>
      )}

      {stats?.recentOrders && stats.recentOrders.length > 0 && (
        <div className="card">
          <h2 className="card-title">Recent Orders</h2>
          <div className="table-wrapper">
            <table>
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Customer</th>
                  <th>Total</th>
                  <th>Status</th>
                  <th>Date</th>
                </tr>
              </thead>
              <tbody>
                {stats.recentOrders.map((order) => (
                  <tr key={order._id}>
                    <td className="order-id">#{order._id.slice(-6)}</td>
                    <td>{order.userId?.name || 'N/A'}</td>
                    <td>Rs.{order.totalPrice?.toLocaleString()}</td>
                    <td>
                      <span className="status-badge" style={{ background: statusColors[order.status] }}>
                        {order.status}
                      </span>
                    </td>
                    <td>{new Date(order.createdAt).toLocaleDateString()}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}
    </div>
  );
}
