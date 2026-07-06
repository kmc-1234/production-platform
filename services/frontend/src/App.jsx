import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { Activity, Bell, Boxes, ShieldCheck } from 'lucide-react';
import './styles.css';

const API_URL = import.meta.env.VITE_API_URL || '/api';
const AUTH_URL = import.meta.env.VITE_AUTH_URL || '/auth';
const NOTIFICATION_URL = import.meta.env.VITE_NOTIFICATION_URL || '/notifications';

function App() {
  const [products, setProducts] = useState([]);
  const [status, setStatus] = useState('Loading');
  const [token, setToken] = useState('');

  useEffect(() => {
    fetch(`${API_URL}/products`)
      .then((res) => res.json())
      .then((body) => {
        setProducts(body.data || []);
        setStatus('Healthy');
      })
      .catch(() => setStatus('Unavailable'));
  }, []);

  async function login() {
    const res = await fetch(`${AUTH_URL}/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'admin@example.com', password: 'demo-password' }),
    });
    const body = await res.json();
    setToken(body.token || '');
  }

  async function notify() {
    await fetch(`${NOTIFICATION_URL}/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ channel: 'email', to: 'ops@example.com', message: 'Platform check completed' }),
    });
  }

  return (
    <main className="shell">
      <aside className="sidebar">
        <div className="brand">Production Platform</div>
        <nav>
          <a className="active">Dashboard</a>
          <a>Services</a>
          <a>Scaling</a>
          <a>Security</a>
        </nav>
      </aside>

      <section className="content">
        <header className="topbar">
          <div>
            <p className="eyebrow">Kubernetes operations live</p>
            <h1>Service Control Plane</h1>
          </div>
          <button onClick={login}><ShieldCheck size={18} /> Login</button>
        </header>

        <div className="metrics">
          <Metric icon={<Activity />} label="API Status" value={status} />
          <Metric icon={<Boxes />} label="Products" value={String(products.length)} />
          <Metric icon={<ShieldCheck />} label="Auth Token" value={token ? 'Issued' : 'Missing'} />
          <Metric icon={<Bell />} label="Notifications" value="Ready" />
        </div>

        <section className="panel">
          <div className="panelHeader">
            <h2>Products</h2>
            <button onClick={notify}><Bell size={18} /> Notify Ops</button>
          </div>
          <table>
            <thead>
              <tr>
                <th>ID</th>
                <th>Name</th>
                <th>Price</th>
              </tr>
            </thead>
            <tbody>
              {products.map((product) => (
                <tr key={product.id}>
                  <td>{product.id}</td>
                  <td>{product.name}</td>
                  <td>${product.price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      </section>
    </main>
  );
}

function Metric({ icon, label, value }) {
  return (
    <div className="metric">
      <div className="metricIcon">{icon}</div>
      <span>{label}</span>
      <strong>{value}</strong>
    </div>
  );
}

createRoot(document.getElementById('root')).render(<App />);
