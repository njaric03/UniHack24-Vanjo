from flask import Flask, request, jsonify
from knowledge_graph.UserGraph import UserGraph
from io import BytesIO
import base64

app = Flask(__name__)

# Load your user graph data or initialize any resources once when the app starts
user_graph = UserGraph.load_from_file('../resources/userbase/userbase_graph.pkl')


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


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
