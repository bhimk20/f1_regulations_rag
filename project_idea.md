Formula 1 Regulations RAG Architecture

This document outlines the architecture for an intelligent retrieval agent built on AWS, designed to accurately answer questions based on Formula 1 sporting and technical regulations.

1. Goal and Portfolio Value

The objective is to build a highly accurate, low-latency Retrieval-Augmented Generation (RAG) system capable of parsing complex, multi-column PDF documents (F1 regulations) and answering specific queries.

Why this is a strong portfolio project:

Complex Data Handling: F1 regulations are dense, highly structured PDFs with tables, cross-references, and strict formatting. Proving you can extract and index this accurately demonstrates advanced data engineering skills.

Cost-Optimized Hybrid Architecture: Implementing a separated index/storage pattern (PostgreSQL + S3) showcases deep understanding of infrastructure cost optimization and system design, going beyond simple "tutorial-level" vector database usage.

Real-World Application: F1 rules are frequently debated. An agent that can instantly cite the exact penalty for "ignoring blue flags during a safety car" is a tangible, impressive use case.

2. Core Architecture Components

This architecture utilizes a hybrid approach, separating the mathematical vector index from the heavy payload storage to optimize both cost and query latency.

A. Data Processing Pipeline (Ingestion)

Raw Storage: Upload raw F1 Regulation PDFs to an Amazon S3 "Landing" Bucket.

PDF Extraction: An AWS Lambda function triggers Amazon Textract. Textract is crucial here because F1 PDFs contain tables and multi-column layouts that basic parsers destroy. Textract preserves the reading order and table structures.

Semantic Enrichment (Optional but Recommended): Pass the extracted text through Amazon Comprehend to identify key entities (e.g., "MGU-K", "Safety Car", "DRS Zone", "Stewards"). These entities become metadata tags.

Chunking & Embedding:

A Python script (running on Lambda or local EC2) chunks the extracted text intelligently (e.g., by regulation article number, not just arbitrary character counts).

Call Amazon Bedrock (Titan Embeddings v2) to convert these chunks into vector representations.

Hybrid Storage Write:

The Payload: Save the raw text chunk and its metadata (from Comprehend) as a JSON file to an Amazon S3 "Processed Vault" Bucket.

The Pointer: Insert the vector, the S3 file path (key), and metadata tags into an Amazon RDS (PostgreSQL with pgvector) instance.

B. Retrieval Pipeline (Querying)

User Query: The user asks a question (e.g., "What is the minimum weight of the car without fuel?").

Query Embedding: Pass the query to Amazon Bedrock (Titan) to generate the query vector.

HNSW Index Search (Low Latency): Query the RDS PostgreSQL pgvector database using the HNSW index to find the nearest vectors.

Advantage: Because the database only holds vectors and pointers, the HNSW graph fits in memory, resulting in millisecond response times.

Pointer Resolution (S3 Fetch): The database returns the S3 keys of the top matches. The application fetches the actual JSON text payloads directly from the S3 "Processed Vault".

Generation: The application passes the retrieved text chunks and the original user query to an LLM via Amazon Bedrock (e.g., Claude 3.5 Sonnet) to generate the final, natural language answer.

3. Storage Optimacy: Cost vs. Latency Trade-offs

This hybrid design specifically addresses the balance between cost and latency.

The Problem with Native Vector DBs (e.g., OpenSearch, Pinecone)

High Cost: Storing gigabytes of raw text inside a vector database requires expensive RAM or NVMe storage. You pay a premium just to host the text payload alongside the index.

The Hybrid Solution (RDS pgvector + S3)

Storage Cost: Amazon S3 is exceptionally cheap (standard tier is ~$0.023 per GB/month). Storing all your processed chunks here minimizes storage costs significantly.

Compute Cost: You only need a small Amazon RDS instance (e.g., a t3.micro or t4g.micro) because the database only needs enough RAM to hold the vectors and the HNSW graph, not the heavy text blobs.

Latency:

Index Search: PostgreSQL HNSW traversal is incredibly fast (typically < 20ms).

Payload Retrieval: Fetching small JSON files from S3 adds a slight delay (typically 30-100ms per file).

Overall: The total retrieval time remains well under a second, which is perfectly acceptable for an agentic chat interface, while keeping monthly infrastructure costs drastically lower than a dedicated OpenSearch cluster.

4. Why Textract and Comprehend?

Amazon Textract: Essential for F1 regulations. Basic libraries (like PyPDF2) read straight across a page, scrambling multi-column layouts and destroying tables (e.g., penalty schedules or dimension limits). Textract understands layout and outputs coherent, readable chunks.

Amazon Comprehend: While optional, passing the Textract output through Comprehend's Medical or Custom Entity Recognition (trained on F1 terms) allows you to extract structured metadata. You can tag chunks with "Aerodynamics", "Power Unit", or "Sporting Penalty". This allows you to add WHERE clauses to your PostgreSQL vector search, drastically improving accuracy by filtering the search space before the vector comparison happens.

5. Next Steps for Implementation

Set up an AWS Account and secure your IAM roles.

Download the latest FIA Formula 1 Sporting and Technical Regulations (PDFs).

Write a local Python script utilizing boto3 to test Amazon Textract on a single page of the regulations to observe the output structure.