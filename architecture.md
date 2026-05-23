# Formula 1 Regulations RAG Architecture

This document visualizes the architecture outlined in our project idea. It leverages a hybrid storage approach to optimize for both low-latency retrieval and cost-efficiency using AWS services.

## Architecture Diagram

```mermaid
flowchart TD
    %% Styling classes
    classDef user fill:#E7157B,stroke:#232F3E,stroke-width:2px,color:white;
    classDef storage fill:#3F8624,stroke:#232F3E,stroke-width:2px,color:white;
    classDef compute fill:#D86613,stroke:#232F3E,stroke-width:2px,color:white;
    classDef ai fill:#00A4A6,stroke:#232F3E,stroke-width:2px,color:white;

    User((User)):::user

    subgraph Ingestion ["1. Data Processing Pipeline (Ingestion)"]
        direction TB
        PDF[Raw F1 Regulations PDFs]
        S3Landing[(S3 Landing Bucket)]:::storage
        Textract[AWS Lambda + Amazon Textract<br><i>PDF Extraction</i>]:::compute
        Comprehend[Amazon Comprehend<br><i>Semantic Enrichment</i>]:::ai
        Embed[Amazon Bedrock Titan<br><i>Chunking & Embeddings</i>]:::ai
        
        PDF --> S3Landing
        S3Landing --> Textract
        Textract -- "Extracted Text" --> Comprehend
        Comprehend -- "Text & Metadata" --> Embed
    end

    subgraph Storage ["2. Hybrid Storage Layer"]
        direction LR
        RDS[(Amazon RDS PostgreSQL<br><i>pgvector HNSW Index</i>)]:::storage
        S3Vault[(S3 Processed Vault<br><i>JSON Text Payloads</i>)]:::storage
    end

    Embed -- "Vectors, S3 Keys, Metadata" --> RDS
    Embed -- "Raw Text JSON" --> S3Vault

    subgraph Retrieval ["3. Retrieval & Generation Pipeline"]
        direction TB
        QEmbed[Amazon Bedrock Titan<br><i>Query Embeddings</i>]:::ai
        VectorSearch[RDS Query Engine<br><i>Nearest Neighbor Search</i>]:::compute
        FetchS3[S3 Fetcher<br><i>Resolve Pointers</i>]:::compute
        LLM[Amazon Bedrock Claude 3.5 Sonnet<br><i>Generation</i>]:::ai
    end

    User -- "Question" --> QEmbed
    QEmbed -- "Query Vector" --> VectorSearch
    VectorSearch -- "HNSW Search" --> RDS
    RDS -- "Top Matches (S3 Keys)" --> FetchS3
    FetchS3 -- "Fetch Payload" --> S3Vault
    S3Vault -- "Text Chunks" --> LLM
    LLM -- "Natural Language Answer" --> User
```

## How It Works

1. **Ingestion Pipeline**: Raw PDFs are dropped into an S3 bucket. A Lambda function triggers Amazon Textract to carefully extract multi-column text and tables without breaking the format. The text is enriched with metadata using Comprehend, embedded using Bedrock Titan, and prepared for storage.
2. **Hybrid Storage**: To save costs on expensive vector database storage, the heavy text payloads are stored as JSON files in a cheap S3 Vault. Only the lightweight mathematical vectors and their corresponding S3 file paths (pointers) are stored in RDS PostgreSQL using the `pgvector` extension.
3. **Retrieval Pipeline**: When a user asks a question, it's embedded into a vector. RDS pgvector quickly finds the nearest neighbors (the most relevant document chunks) and returns their S3 paths. The system fetches the actual text from S3 and passes it to Claude 3.5 Sonnet to generate a precise, context-aware answer.
