import serial
import random

def compute_Q(a, b, c, d):
    Q = ((a - b) * (1 + 3 * c) - 4 * d) / 2
    return Q

def int_to_ascii_bytes(value):
    # Convert signed int (e.g., -12) to list of ASCII byte values
    return [ord(c) for c in str(value)]

def send_ascii_values(serial_port, values):
    for val in values:
        ascii_bytes = int_to_ascii_bytes(val)
        serial_port.write(bytes(ascii_bytes))

def main():
    port = "COM4"
    baudrate = 9600

    try:
        with serial.Serial(port, baudrate, timeout=1) as ser:
            # Ask about baud detect byte
            send_baud = input("Send random baud-detect byte? (y/n): ").strip().lower()
            if send_baud == 'y':
                rand_byte = random.randint(33, 126)  # printable ASCII (no control chars)
                ser.write(bytes([rand_byte]))
                print(f"Sent baud detect byte: '{chr(rand_byte)}' (ASCII {rand_byte})")

            print("\nReady. Press Ctrl+C to stop.\n")

            while True:
                try:
                    a = int(input("Enter signed integer for a: "))
                    b = int(input("Enter signed integer for b: "))
                    c = int(input("Enter signed integer for c: "))
                    d = int(input("Enter signed integer for d: "))

                    Q = compute_Q(a, b, c, d)
                    print("Expected Q =", Q)

                    send_ascii_values(ser, [a, b, c, d])
                    print(f"Sent ASCII bytes for: {a}, {b}, {c}, {d}\n")

                except ValueError:
                    print("Invalid input. Please enter signed integers only.\n")

    except serial.SerialException as e:
        print("Serial error:", e)

if __name__ == "__main__":
    main()

