from flask import Flask, request, jsonify
from knowledge_graph.UserGraph import UserGraph
from io import BytesIO
import base64
import networkx as nx

app = Flask(__name__)

# Load your user graph data or initialize any resources once when the app starts
user_graph = UserGraph.load_from_file('../resources/userbase/userbase_graph.pkl')
user_graph.cycles += user_graph.pending_cycles
user_graph.pending_cycles = []
print(user_graph.graph.nodes['ioPyHMiyE9aUDRzdeQPCujEMM5X2'])

@app.route('/find_cycle', methods=['POST'])
def find_cycle():
    data = request.json
    doc_id = data.get('doc_id')

    if not doc_id:
        return jsonify({"error": "doc_id is required"}), 400

    # Process the cycle for the given document ID
    cycle_nodes, cycle_image_data = user_graph.draw_cycle(doc_id)

    if cycle_nodes is None:
        return jsonify({"error": "No cycle found"}), 404

    # Convert the image to base64
    cycle_image_base64 = base64.b64encode(cycle_image_data).decode('utf-8')

    # Return the cycle data and image to the client
    return jsonify({
        "doc_id": doc_id,
        "cycle_nodes": cycle_nodes,
        "cycle_image": cycle_image_base64
    })

@app.route('/add_user', methods=['POST'])
def add_user():
    data = request.json
    doc_id = data.get('doc_id')
    attributes = data.get('attributes')

    if not doc_id or not attributes:
        return jsonify({"error": "doc_id and attributes are required"}), 400
    try:
        user_graph.add_user(doc_id, attributes)
        print(doc_id in user_graph.graph.nodes)
        return jsonify({"message": "User added successfully", "doc_id": doc_id}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/delete_user', methods=['POST'])
def delete_user():
    data = request.json
    doc_id = data.get('doc_id')

    if not doc_id:
        return jsonify({"error": "doc_id is required"}), 400

    # Remove the user from the graph
    removed = user_graph.remove_user(doc_id)

    if removed:
        return jsonify({"status": "User deleted successfully", "doc_id": doc_id}), 200
    else:
        return jsonify({"error": "User not found"}), 404

if __name__ == '__main__':
    print(user_graph.graph.nodes(data = True)['FX5pjNkaiobajpRTuNBfTkx4JWx1'])
    app.run(debug=True, host='0.0.0.0', port=5000)
