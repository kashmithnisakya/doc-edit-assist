import:py streamlit as st;
import:py requests;


can main() {
    # Set page config for a professional look
    st.set_page_config(page_title="Knowledge Base Assistant", layout="wide");

    # Custom CSS for styling
    st.markdown("""
        <style>
        .main { padding: 2rem; }
        .stButton>button {
            background-color: #1E88E5;
            color: white;
            border-radius: 8px;
            padding: 0.5rem 1rem;
            font-weight: 500;
        }
        .stButton>button:hover {
            background-color: #1565C0;
            color: white;
        }
        .stTextInput>div>input, .stTextArea>div>textarea {
            border-radius: 8px;
            border: 1px solid #E0E0E0;
            padding: 0.5rem;
        }
        .sidebar .sidebar-content {
            background-color: #F5F7FA;
            padding: 1.5rem;
            border-radius: 8px;
        }
        .stAlert {
            border-radius: 8px;
            background-color: #E3F2FD;
            color: #0D47A1;
        }
        h1, h2, h3 { color: #1E88E5; font-family: 'Arial', sans-serif; }
        </style>
    """, unsafe_allow_html=True);

    # Backend URL
    backend_url = "http://localhost:8000";

    # Sidebar for File Upload
    with st.sidebar {
        st.header("Upload Document");
        st.markdown("Upload a PDF or Word document to add to the knowledge base.");
        file = st.file_uploader(label="Choose a file", type=["pdf", "docx", "doc"], help="Supported formats: PDF, DOCX, DOC");
        if file and st.button("Upload File", key="upload_button") {
            with st.spinner("Uploading...") {
                res = requests.post(f"{backend_url}/upload", files={"file": (file.name, file.getvalue())});
                if res.status_code == 200 {
                    st.success(res.json().get("message", "Document uploaded successfully!"));
                } else {
                    st.error("Upload failed. Please try again.");
                }
            }
        }
    }

    # Main content
    st.title("Knowledge Base Assistant");
    st.markdown("Interact with your documents: ask questions or edit sections with ease.");

    # Ask a Question Section
    st.header("Ask a Question");
    st.markdown("Pose a question about your uploaded documents and get instant answers.");
    query = st.text_input("Your question", placeholder="e.g., What is the main topic of the document?", key="query_input");
    if st.button("Submit Question", key="ask_button") {
        if query {
            with st.spinner("Fetching answer...") {
                res = requests.post(f"{backend_url}/ask", params={"query": query});
                if res.status_code == 200 {
                    st.markdown("**Answer:**");
                    st.write(res.json().get("answer", "No answer received."));
                } else {
                    st.error("Failed to get an answer. Please try again.");
                }
            }
        } else {
            st.warning("Please enter a question.");
        }
    }

    # Edit a Section
    st.header("Edit Document Section");
    st.markdown("Paste a section of text and provide instructions to refine it.");
    (col1, col2) = st.columns([2, 1]);
    with col1 {
        section = st.text_area("Section Text", placeholder="Paste the text you want to edit here...", height=150, key="section_input");
    }
    with col2 {
        instruction = st.text_input("Editing Instruction", placeholder="e.g., Make it shorter", key="instruction_input");
    }
    if st.button("Suggest Edit", key="edit_button") {
        if section and instruction {
            with st.spinner("Generating edit...") {
                res = requests.post(f"{backend_url}/edit", json={"section_text": section, "instruction": instruction});
                if res.status_code == 200 {
                    st.markdown("**Edited Text:**");
                    st.write(res.json().get("edited_text", "No edited text received."));
                } else {
                    st.error("Edit failed. Please try again.");
                }
            }
        } else {
            st.warning("Please provide both section text and an instruction.");
        }
    }
    # Footer
    st.markdown("---");
    st.markdown("Built with Jac | Powered by Jivas");
}