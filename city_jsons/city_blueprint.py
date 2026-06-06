import base64
import zlib
import json

def decode_blueprint(bp_string):
    # Factorio strings start with a version byte (usually '0')
    # We strip the first character and decode the rest from Base64
    decoded_data = base64.b64decode(bp_string[1:])
    # Decompress using zlib
    json_data = zlib.decompress(decoded_data)
    return json.loads(json_data)

def encode_blueprint(data):
    # Convert JSON to string, compress, and encode to Base64
    # separators=(',', ':') removes whitespace to match Factorio's formatting
    json_str = json.dumps(data, separators=(',', ':'))
    compressed = zlib.compress(json_str.encode('utf-8'), level=9)
    # Prepend the version byte '0' back onto the string
    return '0' + base64.b64encode(compressed).decode('utf-8')

def center_blueprint(bp_data):
    if "blueprint" not in bp_data or "entities" not in bp_data["blueprint"]:
        return bp_data

    entities = bp_data["blueprint"]["entities"]
    
    # 1. Find the raw coordinate edges
    min_x = min(e["position"]["x"] for e in entities)
    max_x = max(e["position"]["x"] for e in entities)
    min_y = min(e["position"]["y"] for e in entities)
    max_y = max(e["position"]["y"] for e in entities)

    # 2. Calculate raw midpoint
    raw_offset_x = (min_x + max_x) / 2
    raw_offset_y = (min_y + max_y) / 2

    # 3. Snap to the nearest 0.5 or 1.0 grid tile to preserve 
    # Factorio's grid alignment and keep distances perfectly symmetrical.
    offset_x = round(raw_offset_x * 2) / 2
    offset_y = round(raw_offset_y * 2) / 2

    # 4. Shift all entities
    for e in entities:
        e["position"]["x"] = round(e["position"]["x"] - offset_x, 4)
        e["position"]["y"] = round(e["position"]["y"] - offset_y, 4)
        
    # Shift tiles if they exist
    if "tiles" in bp_data["blueprint"]:
        for t in bp_data["blueprint"]["tiles"]:
            t["position"]["x"] = round(t["position"]["x"] - offset_x, 4)
            t["position"]["y"] = round(t["position"]["y"] - offset_y, 4)

    return bp_data

def main():
    try:
        # Read from file
        with open("building.txt", "r") as f:
            bp_string = f.read().strip()

        # Process the blueprint
        data = decode_blueprint(bp_string)
        centered_data = center_blueprint(data)
        new_bp_string = encode_blueprint(centered_data)

        # Output the centered JSON data (pretty-printed for readability)
        with open("result.json", "w") as json_file:
            json.dump(centered_data, json_file, indent=4)
        print("Successfully saved centered JSON to result.json")

        # Output the new blueprint string
        with open("result.txt", "w") as txt_file:
            txt_file.write(new_bp_string)
        print("Successfully saved centered blueprint string to result.txt")

    except FileNotFoundError:
        print("Error: building.txt not found. Please ensure it exists in the same directory.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    main()