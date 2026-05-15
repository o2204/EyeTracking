import time


class BlinkDetector:
    def __init__(self):
        self.last_blink_time = 0
        self.double_blink_threshold = 0.5
        self.cooldown = 1
        self.last_click_time = 0

    def update(self, is_blinking: bool):
        current_time = time.time()

        if is_blinking:
            # prevent spam clicks
            if current_time - self.last_click_time < self.cooldown:
                return None

            if current_time - self.last_blink_time < self.double_blink_threshold:
                self.last_blink_time = 0
                self.last_click_time = current_time
                return "double_blink"

            self.last_blink_time = current_time

        return None