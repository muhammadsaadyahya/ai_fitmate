import os
import requests
from dotenv import load_dotenv
from sentence_transformers import SentenceTransformer
from pinecone import Pinecone

load_dotenv()

# ── Config ────────────────────────────────────────────────────────────────────
GROQ_API_KEY        = os.getenv("GROQ_API_KEY")
PINECONE_API_KEY    = os.getenv("PINECONE_API_KEY")
PINECONE_INDEX_NAME = os.getenv("PINECONE_INDEX_NAME", "fitness-kb")
EMBED_MODEL         = "all-MiniLM-L6-v2"
TOP_K               = 5
GROQ_API_URL        = "https://api.groq.com/openai/v1/chat/completions"

_embedder = None
_index    = None


def _get_embedder():
    global _embedder
    if _embedder is None:
        print("Loading embedding model...")
        _embedder = SentenceTransformer(EMBED_MODEL)
    return _embedder


def _get_index():
    global _index
    if _index is None:
        if not PINECONE_API_KEY:
            raise RuntimeError("PINECONE_API_KEY is not set in .env")
        pc = Pinecone(api_key=PINECONE_API_KEY)
        _index = pc.Index(PINECONE_INDEX_NAME)
    return _index


# ── Retrieval ─────────────────────────────────────────────────────────────────
def retrieve(query: str, top_k: int = TOP_K) -> list[str]:
    """Embed query and fetch top-k matching documents from Pinecone."""
    embedding = _get_embedder().encode([query])[0].tolist()
    results = _get_index().query(
        vector=embedding,
        top_k=top_k,
        include_metadata=True,
    )
    return [match["metadata"]["text"] for match in results["matches"]]


# ── Prompt builder ────────────────────────────────────────────────────────────
def build_prompt(context_chunks: list[str], question: str) -> str:
    context_text = "\n\n".join(context_chunks)
    return f"""You are a helpful fitness coach. Use the fitness knowledge below to answer the question.

Your task:
- Read through the fitness Q&A examples below
- Use the information to answer the user's new question
- Synthesize and combine information from multiple examples if needed
- Give practical, actionable advice
- If the context has related information, use it to give a helpful answer
- Only say "I don't have information about that" if the context is completely unrelated

Fitness Knowledge:
{context_text}

User Question: {question}

Your Answer:"""


# ── LLM call ──────────────────────────────────────────────────────────────────
def generate_answer(prompt: str) -> str:
    try:
        response = requests.post(
            GROQ_API_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": "llama-3.3-70b-versatile",
                "messages": [
                    {
                        "role": "system",
                        "content": (
                            "You are a knowledgeable fitness coach. "
                            "When given fitness Q&A examples, use them to answer new related questions. "
                            "Don't just match exact questions — understand the concepts and apply them."
                        ),
                    },
                    {"role": "user", "content": prompt},
                ],
                "temperature": 0.7,
                "max_tokens": 400,
            },
            timeout=30,
        )

        result = response.json()

        if response.status_code != 200:
            error_msg = result.get("error", {})
            return f"⚠️ API Error: {error_msg}"

        if "choices" in result and result["choices"]:
            return result["choices"][0]["message"]["content"]

        return "⚠️ Unexpected response format."

    except requests.exceptions.RequestException as e:
        return f"⚠️ Request failed: {e}"


# ── Public API ────────────────────────────────────────────────────────────────
def ask_bot(question: str) -> str:
    """Full RAG pipeline: retrieve from Pinecone → build prompt → generate answer."""
    contexts = retrieve(question)
    prompt = build_prompt(contexts, question)
    return generate_answer(prompt)


# ── CLI ───────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("Fitness Chatbot (Pinecone) Ready! Type 'exit' to quit.\n")
    while True:
        user_input = input("You: ").strip()
        if user_input.lower() in ("exit", "quit"):
            break
        if not user_input:
            continue
        answer = ask_bot(user_input)
        print(f"\nBot: {answer}\n")
