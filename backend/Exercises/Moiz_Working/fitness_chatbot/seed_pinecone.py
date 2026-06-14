"""
Run this ONCE to embed and upsert the fitness knowledge base into Pinecone.

Usage:
    python seed_pinecone.py

Prerequisites:
    - PINECONE_API_KEY set in .env
    - PINECONE_INDEX_NAME set in .env
    - Index must be created in Pinecone Console with dimension=384, metric=cosine
"""

import os
import sys
import time
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from pinecone import Pinecone
from knowledge_base import DOCUMENTS

load_dotenv()

PINECONE_API_KEY = os.getenv("PINECONE_API_KEY")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME", "fitness-kb")
EMBED_MODEL = "all-MiniLM-L6-v2"
BATCH_SIZE = 50


def main():
    if not PINECONE_API_KEY:
        print("ERROR: PINECONE_API_KEY not found in .env")
        sys.exit(1)

    print(f"Loading embedding model: {EMBED_MODEL}")
    embedder = SentenceTransformer(EMBED_MODEL)

    print("Connecting to Pinecone...")
    pc = Pinecone(api_key=PINECONE_API_KEY)
    index = pc.Index(PINECONE_INDEX_NAME)

    stats = index.describe_index_stats()
    index_dim = stats.get('dimension', 'unknown')
    print(f"Index '{PINECONE_INDEX_NAME}' — dimension: {index_dim}, current vector count: {stats['total_vector_count']}")
    if index_dim != 384:
        print(f"\nERROR: Index dimension is {index_dim} but the embedding model outputs 384.")
        print("Fix: Delete the index in Pinecone Console and recreate it with dimension=384, metric=cosine.")
        sys.exit(1)

    print(f"\nEmbedding {len(DOCUMENTS)} documents...")
    texts = [doc["text"] for doc in DOCUMENTS]
    embeddings = embedder.encode(texts, show_progress_bar=True, batch_size=32)

    print("\nUpserting to Pinecone in batches...")
    vectors = [
        {
            "id": doc["id"],
            "values": embeddings[i].tolist(),
            "metadata": {
                "text": doc["text"],
                "category": doc["category"],
                "topic": doc["topic"],
            },
        }
        for i, doc in enumerate(DOCUMENTS)
    ]

    for start in range(0, len(vectors), BATCH_SIZE):
        batch = vectors[start : start + BATCH_SIZE]
        index.upsert(vectors=batch)
        print(f"  Upserted {min(start + BATCH_SIZE, len(vectors))}/{len(vectors)}")
        time.sleep(0.5)

    time.sleep(2)
    stats = index.describe_index_stats()
    print(f"\nDone. Index now has {stats['total_vector_count']} vectors.")


if __name__ == "__main__":
    main()
