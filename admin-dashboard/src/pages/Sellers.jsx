import { useState, useEffect } from 'react';
import api from '../services/api';
import { toast } from 'react-toastify';
import { FiPlus, FiUserCheck, FiUserX, FiX } from 'react-icons/fi';

export default function Sellers() {
  const [sellers, setSellers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: '', email: '', password: '', phone: '', address: '' });
  const [submitting, setSubmitting] = useState(false);

  useEffect(() => { fetchSellers(); }, []);

  const fetchSellers = async () => {
    try {
      const res = await api.get('/admin/sellers');
      setSellers(res.data.data);
    } catch (err) {
      toast.error('Failed to load sellers');
    } finally {
      setLoading(false);
    }
  };

  const handleCreate = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    try {
      await api.post('/admin/sellers', form);
      toast.success('Seller created!');
      setShowModal(false);
      setForm({ name: '', email: '', password: '', phone: '', address: '' });
      fetchSellers();
    } catch (err) {
      toast.error(err.response?.data?.message || 'Failed to create seller');
    } finally {
      setSubmitting(false);
    }
  };

  const toggleSeller = async (id) => {
    try {
      const res = await api.put(`/admin/sellers/${id}/toggle`);
      toast.success(res.data.message);
      fetchSellers();
    } catch (err) {
      toast.error('Failed to update seller');
    }
  };

  if (loading) return <div className="loading-spinner">Loading...</div>;

  return (
    <div className="sellers-page">
      <div className="page-header">
        <h1 className="page-title">Sellers</h1>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}>
          <FiPlus /> Add Seller
        </button>
      </div>

      <div className="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>Name</th>
              <th>Email</th>
              <th>Phone</th>
              <th>Status</th>
              <th>Joined</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {sellers.length === 0 ? (
              <tr><td colSpan="6" className="empty-state">No sellers yet</td></tr>
            ) : (
              sellers.map((s) => (
                <tr key={s._id}>
                  <td>{s.name}</td>
                  <td>{s.email}</td>
                  <td>{s.phone}</td>
                  <td>
                    <span className={`status-badge ${s.role === 'seller' ? 'active' : 'blocked'}`}>
                      {s.role === 'seller' ? 'Active' : 'Blocked'}
                    </span>
                  </td>
                  <td>{new Date(s.createdAt).toLocaleDateString()}</td>
                  <td>
                    <button
                      className={`btn-icon ${s.role === 'seller' ? 'delete' : 'edit'}`}
                      onClick={() => toggleSeller(s._id)}
                      title={s.role === 'seller' ? 'Block' : 'Activate'}
                    >
                      {s.role === 'seller' ? <FiUserX /> : <FiUserCheck />}
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>Add Seller</h2>
              <button className="btn-icon" onClick={() => setShowModal(false)}><FiX /></button>
            </div>
            <form onSubmit={handleCreate} className="modal-form">
              <div className="form-group">
                <label>Name</label>
                <input value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} required />
              </div>
              <div className="form-group">
                <label>Email</label>
                <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} required />
              </div>
              <div className="form-group">
                <label>Password</label>
                <input type="password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} required minLength={6} />
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Phone</label>
                  <input value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} required />
                </div>
                <div className="form-group">
                  <label>Address</label>
                  <input value={form.address} onChange={(e) => setForm({ ...form, address: e.target.value })} required />
                </div>
              </div>
              <div className="modal-actions">
                <button type="button" className="btn btn-secondary" onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" disabled={submitting}>
                  {submitting ? 'Creating...' : 'Create Seller'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
