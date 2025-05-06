
import serial
import random

def compute_Q(a, b, c, d):
    return ((a - b) * (1 + 3 * c) - 4 * d) / 2

def int_to_ascii_bytes(value):
    return [ord(c) for c in str(value)]

def send_ascii_values(serial_port, values):
    for val in values:
        ascii_bytes = int_to_ascii_bytes(val)
        serial_port.write(bytes(ascii_bytes))

def receive_uart_number(serial_port):
    print("Receiving 5 ASCII bytes representing a signed number...")
    received = serial_port.read(5)

    if len(received) != 5:
        print(" Incomplete data received or timeout.")
        return None

    sign_char = chr(received[0])
    digits = ''.join(chr(b) for b in received[1:])

    try:
        number = int(digits)
        if sign_char == '-':
            number = -number
        return number
    except ValueError:
        print(" Received invalid ASCII digits.")
        return None

def compare_results(expected, received):
    print(f"\nExpected Q = {expected}")
    print(f"Received Q = {received}")
    if received == int(expected):  # cast to int if UART only sends int result
        print("SUCCESS: Values match!\n")
    else:
        print(" FAILED: Values do not match.\n")

def main():
    port = "COM10"
    baudrate = 9600

    try:
        with serial.Serial(port, baudrate, timeout=1) as ser:
            send_baud = input("Send random baud-detect byte? (y/n): ").strip().lower()
            if send_baud == 'y':
                rand_byte = random.randint(33, 126)
                ser.write(bytes([rand_byte]))
                print(f"Sent baud detect byte: '{chr(rand_byte)}' (ASCII {rand_byte})")

            print("\n✨ Ready. Press Ctrl+C to stop. ✨\n")

            while True:
                try:
                    a = int(input("Enter signed integer for a: "))
                    b = int(input("Enter signed integer for b: "))
                    c = int(input("Enter signed integer for c: "))
                    d = int(input("Enter signed integer for d: "))

                    Q = compute_Q(a, b, c, d)

                    send_ascii_values(ser, [a, b, c, d])
                    print(f"📤 Sent: {a}, {b}, {c}, {d}")

                    received_Q = receive_uart_number(ser)
                    if received_Q is not None:
                        compare_results(Q, received_Q)

                except ValueError:
                    print(" Invalid input. Please enter signed integers only.\n")

    except serial.SerialException as e:
        print(" Serial error:", e)

if __name__ == "__main__":
    main()

