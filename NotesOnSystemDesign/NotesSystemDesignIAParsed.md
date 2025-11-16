Of course. Here are the study notes from the provided transcript, organized by subject in Markdown format.

---

# System Design Study Notes

## 1. Fundamentals of Computer Architecture

A high-level overview of how a single computer functions, forming the foundation for distributed systems.

### Core Components

- **Disk Storage (HDD/SSD)**

  - **Purpose:** Long-term, non-volatile storage. Holds the OS, applications, and user files.
  - **Volatility:** Non-volatile (data persists without power).
  - **Types:**
    - **HDD (Hard Disk Drive):** Slower (80-160 MB/s), cheaper.
    - **SSD (Solid State Drive):** Significantly faster (500-3,500 MB/s), more expensive.
  - **Size:** Hundreds of gigabytes to multiple terabytes.

- **RAM (Random Access Memory)**

  - **Purpose:** Primary workspace for active data. Holds data structures, variables, and application data currently in use.
  - **Volatility:** Volatile (data is lost without power).
  - **Speed:** Very fast, often exceeding 5,000 MB/s, much faster than SSDs.
  - **Size:** A few gigabytes in consumer devices to hundreds in servers.

- **CPU Cache (L1, L2, L3)**

  - **Purpose:** Extremely fast, small memory to store frequently accessed data and reduce the average time to access data from RAM.
  - **Access Hierarchy:** CPU checks L1 -> L2 -> L3 -> RAM.
  - **Volatility:** Volatile.
  - **Speed:** Nanosecond access times, even faster than RAM.
  - **Size:** Measured in megabytes (much smaller than RAM).

- **CPU (Central Processing Unit)**

  - **Purpose:** The "brain" of the computer. It fetches, decodes, and executes instructions.
  - **Process:**
    1.  High-level code (Java, Python) is compiled into machine code (binary).
    2.  The CPU executes this machine code, processing operations and reading/writing from cache, RAM, and disk.

- **Motherboard**
  - **Purpose:** The central circuit board that connects all components (CPU, RAM, Disk, etc.), allowing data to flow between them.

---

## 2. High-Level Production Architecture

The ecosystem of tools and processes that support a running application.

### Key Components

- **CI/CD Pipeline (Continuous Integration/Deployment)**

  - **Function:** Automates the process of moving code from a repository to production.
  - **Process:** Code -> Tests -> Pipeline Checks -> Deployed to Server.
  - **Tools:** Jenkins, GitHub Actions.

- **Load Balancers & Reverse Proxies**

  - **Function:** Distribute incoming user requests evenly across multiple application servers.
  - **Benefits:** Prevents server overload, ensures a smooth user experience, improves availability.
  - **Tools:** NGINX.

- **External Services**

  - **Storage:** Production servers connect to external storage servers over a network.
  - **Other Services:** Applications often communicate with other microservices.

- **Logging & Monitoring**

  - **Function:** Keep a detailed record of application events, performance metrics, and errors.
  - **Best Practice:** Store logs on external, dedicated services (not on the production server).
  - **Tools:**
    - **Backend:** PM2
    - **Frontend:** Sentry

- **Alerting**
  - **Function:** Automatically notifies developers when the monitoring system detects anomalies or failures.
  - **Integration:** Alerts are often sent to platforms like Slack for instant visibility and response.

### The Debugging Workflow

1.  **Identify:** Use logs to find patterns or anomalies pointing to the problem's source.
2.  **Replicate:** Reproduce the issue in a safe **staging** or **test** environment. **Never debug directly in production.**
3.  **Debug:** Use debugging tools to inspect the application state and find the root cause.
4.  **Hotfix:** Roll out a quick, temporary patch to get the system running again while a permanent solution is developed.

---

## 3. Pillars of System Design & Key Metrics

The core principles and measurements that define a well-designed system.

### Foundational Principles

- **Scalability:** The system's ability to handle growing load and user base.
- **Maintainability:** The ease with which future developers can understand, modify, and improve the system.
- **Efficiency:** Making the best use of available resources (CPU, memory, bandwidth).
- **Resilience:** The ability to perform well and maintain composure even when parts of the system fail.

### The CAP Theorem (Brewer's Theorem)

A distributed system can only simultaneously guarantee **two** of the following three properties:

1.  **Consistency (C):** Every read receives the most recent write or an error. All nodes in the system have the same data at the same time.
2.  **Availability (A):** Every request receives a (non-error) response, without the guarantee that it contains the most recent write. The system is always operational.
3.  **Partition Tolerance (P):** The system continues to operate despite a network partition (a communication break between nodes). _In modern distributed systems, Partition Tolerance is generally considered mandatory._

This forces a tradeoff, typically between Consistency and Availability (CP vs. AP systems).

### Key Performance & Reliability Metrics

- **Availability**

  - **Definition:** The percentage of time a system is operational and available to users.
  - **Measurement:** Often described in "nines".
    - `99.9%` (3 nines) = ~8.76 hours of downtime/year.
    - `99.999%` (5 nines) = ~5.26 minutes of downtime/year.
  - **SLO (Service Level Objective):** An internal goal for system performance (e.g., "99.9% of requests should respond in <300ms").
  - **SLA (Service Level Agreement):** A formal contract with users guaranteeing a minimum level of service, with penalties for failure.

- **Reliability, Fault Tolerance, Redundancy**

  - **Reliability:** The system works correctly and consistently.
  - **Fault Tolerance:** The system can handle unexpected failures gracefully.
  - **Redundancy:** Having backup components ready to take over if a primary one fails.

- **Throughput & Latency**
  - **Throughput:** How much data/work a system can handle over a period.
    - **RPS (Requests Per Second):** Server throughput.
    - **QPS (Queries Per Second):** Database throughput.
  - **Latency:** The time it takes to handle a single request (from request to response).
  - **Tradeoff:** Increasing throughput (e.g., by batching requests) can sometimes increase latency.

---

## 4. Networking Basics

How computers communicate over a network.

### Core Concepts

- **IP Address (Internet Protocol)**

  - **Purpose:** A unique numerical identifier for a device on a network.
  - **Versions:**
    - **IPv4:** 32-bit (~4 billion addresses).
    - **IPv6:** 128-bit (vastly more addresses).
  - **Data Packets:** Data is sent in packets, each containing an IP header with the sender and receiver's IP addresses.

- **TCP (Transmission Control Protocol)**

  - **Layer:** Transport Layer.
  - **Characteristics:**
    - **Reliable & Connection-Oriented:** Establishes a connection via a **3-way handshake** before sending data.
    - **Ordered Delivery:** Uses sequence numbers to ensure packets are reassembled in the correct order.
    - **Use Cases:** Web browsing (HTTP), email, file transfers. Where data integrity is crucial.

- **UDP (User Datagram Protocol)**

  - **Layer:** Transport Layer.
  - **Characteristics:**
    - **Unreliable & Connectionless:** Sends packets without establishing a connection.
    - **No Guarantees:** Does not guarantee delivery or order.
    - **Fast & Low-Overhead:** Less overhead makes it faster than TCP.
    - **Use Cases:** Video streaming, online gaming, VoIP. Where speed is more important than perfect data integrity.

- **DNS (Domain Name System)**
  - **Purpose:** The "phonebook of the internet." Translates human-readable domain names (e.g., `google.com`) into machine-readable IP addresses.
  - **Oversight:** Managed by organizations like ICANN.
  - **Registrars:** Companies like GoDaddy or Namecheap sell domain names.
  - **Record Types:**
    - **A Record:** Maps a domain to an IPv4 address.
    - **AAAA (Quad A) Record:** Maps a domain to an IPv6 address.

### Infrastructure Concepts

- **Public vs. Private IP:** Public IPs are unique across the internet; Private IPs are unique within a local network (LAN).
- **Static vs. Dynamic IP:** Static IPs are permanently assigned; Dynamic IPs are assigned temporarily and can change.
- **Firewall:** A security device that monitors and controls incoming and outgoing network traffic based on predefined security rules.
- **Port:** A number that identifies a specific process or service on a device (e.g., Port 80 for HTTP, Port 22 for SSH). An IP address gets you to the computer; a port number gets you to the right application on that computer.

---

## 5. Application Layer Protocols

The protocols that applications use to communicate.

- **HTTP (HyperText Transfer Protocol)**

  - **Foundation:** Built on TCP/IP.
  - **Model:** A stateless request-response protocol. Each request is independent.
  - **Common Methods:**
    - `GET`: Retrieve data.
    - `POST`: Create new data.
    - `PUT`/`PATCH`: Update existing data.
    - `DELETE`: Remove data.
  - **Status Codes:**
    - `2xx`: Success (e.g., `200 OK`).
    - `3xx`: Redirection (e.g., `301 Moved Permanently`).
    - `4xx`: Client Error (e.g., `404 Not Found`, `400 Bad Request`).
    - `5xx`: Server Error (e.g., `500 Internal Server Error`).

- **WebSockets**

  - **Purpose:** Provides a persistent, two-way communication channel over a single TCP connection.
  - **Use Case:** Real-time applications like chat apps, live sports updates, stock tickers. Allows the server to "push" data to the client without the client having to constantly ask for it.

- **Email Protocols**

  - **SMTP (Simple Mail Transfer Protocol):** For **sending** emails between servers.
  - **IMAP/POP3:** For **retrieving** emails from a server to a client.

- **File & Remote Access Protocols**

  - **FTP (File Transfer Protocol):** For transferring files between a client and server.
  - **SSH (Secure Shell):** For secure remote login, command execution, and file transfers over an unsecured network.

- **Other Important Protocols**
  - **WebRTC:** Enables real-time browser-to-browser communication (voice, video, file sharing).
  - **MQTT/AMQP:** Lightweight messaging protocols often used for IoT devices and message-oriented middleware (like RabbitMQ).
  - **RPC (Remote Procedure Call):** Allows a program to execute a procedure/function on a remote computer as if it were a local call.

---

## 6. API Design

Creating the interface for how different software components interact.

### API Paradigms

- **REST (REpresentational State Transfer)**

  - **Concept:** An architectural style using standard HTTP methods and conventions.
  - **Pros:** Simple, widely understood, stateless.
  - **Cons:** Can lead to **over-fetching** (getting more data than needed) or **under-fetching** (requiring multiple calls to get all needed data).
  - **Data Format:** Typically JSON.

- **GraphQL**

  - **Concept:** A query language for APIs. The client specifies exactly what data it needs.
  - **Pros:** Solves over/under-fetching, strongly typed schema.
  - **Cons:** Can lead to complex server-side queries; error handling is done within the response body (usually with a `200 OK` status).
  - **Method:** Uses `POST` for all operations (queries and mutations).

- **gRPC (Google Remote Procedure Call)**
  - **Concept:** A high-performance RPC framework.
  - **Pros:** Highly efficient due to **Protocol Buffers** (a binary serialization format) and HTTP/2. Ideal for microservices communication.
  - **Cons:** Less human-readable than JSON, requires HTTP/2 support.

### Best Practices

- **Endpoint Naming:** Use nouns for resources (e.g., `/users`, `/products/{productId}/orders`).
- **Idempotency:** `GET`, `PUT`, `DELETE` requests should be idempotent (making the same call multiple times produces the same result). `GET` should never mutate data.
- **Versioning:** To avoid breaking existing clients, introduce new versions of your API (e.g., `/v2/products`).
- **Pagination & Filtering:** Use query parameters to limit results and allow filtering (e.g., `/products?limit=50&offset=100`, `/orders?startDate=...`).
- **Rate Limiting:** Control the number of requests a user can make in a given time frame to prevent abuse and DoS attacks.
- **CORS (Cross-Origin Resource Sharing):** Configure server settings to control which other domains are allowed to make requests to your API.

---

## 7. Caching & Content Delivery Networks (CDNs)

Techniques for storing data temporarily to serve requests faster.

### Caching Fundamentals

- **Purpose:** Improve performance by storing copies of data in a temporary, fast-access location.
- **Cache Hit:** The requested data is found in the cache.
- **Cache Miss:** The requested data is not in the cache and must be fetched from the original source.
- **Cache Hit Ratio:** (Cache Hits / Total Requests) - a higher ratio means a more effective cache.

### Caching Locations

1.  **Browser Cache:** Stores static assets (HTML, CSS, JS, images) on the user's local machine. Controlled by the `Cache-Control` HTTP header.
2.  **Server Cache:** Stores frequently accessed data on the server side (e.g., in-memory with Redis) to avoid expensive operations like database queries.
3.  **Database Cache:** The database system itself often caches query results.
4.  **CDN (Content Delivery Network):** A geographically distributed network of proxy servers that cache static content.

### Server-Side Caching Strategies

- **Write-Around:** Write directly to storage, bypassing the cache. The cache is populated on a read miss.
- **Write-Through:** Write to both the cache and permanent storage simultaneously. Ensures consistency but can be slower.
- **Write-Back:** Write to the cache first, and then to storage at a later time. Improves write performance but risks data loss if the cache server fails before the write to storage is complete.

### Cache Eviction Policies

When the cache is full, rules are needed to decide what to remove:

- **LRU (Least Recently Used):** Evict the item that hasn't been accessed for the longest time.
- **FIFO (First-In, First-Out):** Evict the oldest item.
- **LFU (Least Frequently Used):** Evict the item that has been accessed the fewest times.

### Content Delivery Networks (CDNs)

- **How it Works:** When a user requests content (e.g., an image), the request is routed to the nearest CDN server (edge location). If the CDN has the content cached, it serves it directly. If not, it fetches it from the origin server, caches it, and then delivers it to the user.
- **Types:**
  - **Pull CDN:** The CDN pulls content from the origin server when it's first requested.
  - **Push CDN:** The developer actively pushes content to the CDN's storage.
- **Benefits:**
  - **Reduced Latency:** Content is served from a location closer to the user.
  - **High Availability:** Distributes load and is resilient to failures.
  - **Improved Security:** Many CDNs offer DDoS protection.
  - **Reduced Load on Origin Server:** The CDN handles most requests for static assets.

---

## 8. Proxy Servers & Load Balancing

Intermediaries that manage and route network traffic.

### Proxy Servers

- **Forward Proxy:**

  - **Position:** Sits in front of **client(s)**.
  - **Function:** Forwards requests from an internal network to the internet. **Hides the client's identity.**
  - **Use Cases:** Bypassing content filters, corporate network security, anonymizing user activity.

- **Reverse Proxy:**
  - **Position:** Sits in front of **server(s)**.
  - **Function:** Receives requests from the internet and forwards them to the appropriate backend server. **Hides the server's identity.**
  - **Use Cases:**
    - **Load Balancing**
    - **CDNs**
    - **Web Application Firewalls (WAFs)**
    - **SSL Offloading** (handling encryption/decryption to free up web servers).

### Load Balancing

- **Purpose:** To distribute incoming traffic across multiple backend servers to ensure no single server becomes a bottleneck, thereby increasing availability and reliability.

- **Common Algorithms:**

  - **Round Robin:** Sequentially gives requests to each server in a loop. Best for servers with similar capabilities.
  - **Least Connections:** Sends the request to the server with the fewest active connections.
  - **Least Response Time:** Sends the request to the server with the lowest response time.
  - **IP Hashing:** Uses a hash of the client's IP to determine the server. Ensures a client is always sent to the same server (useful for session persistence).
  - **Weighted Variations:** Assigns a "weight" to each server based on its capacity, allowing more powerful servers to handle more traffic.
  - **Consistent Hashing:** A more advanced hashing method that minimizes disruption when servers are added or removed from the pool.

- **Health Checks:** The load balancer continuously checks the health of backend servers and stops sending traffic to any that fail.

- **Single Point of Failure:** A single load balancer can be a point of failure. This is mitigated by using a **redundant (failover) pair** of load balancers.

---

## 9. Database Essentials

The core of data storage in system design.

### Database Types

- **Relational Databases (SQL)**

  - **Structure:** Data is organized in tables with predefined schemas (rows and columns). Relationships are enforced with foreign keys.
  - **Query Language:** SQL (Structured Query Language).
  - **Key Properties (ACID):**
    - **A**tomicity: Transactions are all-or-nothing.
    - **C**onsistency: Transactions bring the database from one valid state to another.
    - **I**solation: Concurrent transactions do not affect each other.
    - **D**urability: Once a transaction is committed, it remains so, even in the event of power loss.
  - **Examples:** PostgreSQL, MySQL, SQL Server.
  - **Best For:** Applications requiring high data integrity and complex transactions (e.g., banking, e-commerce).

- **NoSQL Databases (Not Only SQL)**

  - **Structure:** Flexible schemas. Data can be stored as documents, key-value pairs, graphs, etc.
  - **Key Properties:** Generally prioritizes availability and scalability over strict consistency (often BASE - Basically Available, Soft state, Eventual consistency).
  - **Types & Examples:**
    - **Document:** MongoDB
    - **Key-Value:** Redis, DynamoDB
    - **Graph:** Neo4j
  - **Best For:** Unstructured data, large-scale applications, high write loads, and rapid development.

- **In-Memory Databases**
  - **Structure:** Stores data primarily in RAM.
  - **Examples:** Redis, Memcached.
  - **Best For:** Caching, session storage, real-time analytics where speed is paramount.

### Database Scaling

- **Vertical Scaling (Scale Up):** Increasing the resources (CPU, RAM, SSD) of a single server.

  - **Pros:** Simple to implement.
  - **Cons:** Has a physical limit, can be expensive, creates a single point of failure.

- **Horizontal Scaling (Scale Out):** Adding more servers to a database cluster.
  - **Pros:** Highly scalable, improves fault tolerance.
  - **Cons:** More complex to manage.
  - **Techniques:**
    1.  **Replication:** Creating copies of the database.
        - **Master-Slave:** One master server handles all writes, which are then replicated to multiple read-only slave servers. Good for read-heavy applications.
        - **Master-Master:** Multiple servers can handle both reads and writes. More complex to keep consistent.
    2.  **Sharding (Partitioning):** Splitting a large database into smaller, more manageable pieces (shards) and distributing them across multiple servers.

### Database Performance Techniques

- **Caching:** Use an in-memory database like Redis to cache frequent query results.
- **Indexing:** Create indexes on columns that are frequently used in `WHERE` clauses to speed up read queries significantly. (Note: Indexes can slow down write operations).
- **Query Optimization:** Analyze and rewrite slow queries. Use tools like `EXPLAIN` to understand how the database is executing a query and identify bottlenecks.
