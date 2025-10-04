from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Configure PostgreSQL database
app.config["SQLALCHEMY_DATABASE_URI"] = "postgresql://username:password@localhost:5432/closet_db"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

db = SQLAlchemy(app)

# Define a model for clothing items
class ClothingItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    image_url = db.Column(db.String(200), nullable=True)

# Create the database tables (Run once before starting the app)
with app.app_context():
    db.create_all()

# Route to add a clothing item
@app.route("/add", methods=["POST"])
def add_item():
    data = request.json
    new_item = ClothingItem(name=data["name"], category=data["category"], image_url=data.get("image_url"))
    db.session.add(new_item)
    db.session.commit()
    return jsonify({"message": "Item added successfully!"}), 201

# Route to get all clothing items
@app.route("/items", methods=["GET"])
def get_items():
    items = ClothingItem.query.all()
    return jsonify([{"id": item.id, "name": item.name, "category": item.category, "image_url": item.image_url} for item in items])

# Route to delete an item
@app.route("/delete/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    item = ClothingItem.query.get(item_id)
    if not item:
        return jsonify({"error": "Item not found"}), 404
    db.session.delete(item)
    db.session.commit()
    return jsonify({"message": "Item deleted successfully"}), 200

if __name__ == "__main__":
    app.run(debug=True)
