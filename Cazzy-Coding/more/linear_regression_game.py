import numpy as np
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider, Button

# --- Generate sample non-linear data ---
np.random.seed(88)
x = np.linspace(0, 10, 50)
y_true = 2 * np.sin(x) + 0.5 * x
y_noise = y_true + np.random.normal(0, 1, size=x.shape)

# --- Initial guess for non-linear regression: y = a*sin(b*x) + c*x ---
a_init, b_init, c_init = 1.0, 1.0, 1.0

# --- Create plot ---
fig, ax = plt.subplots()
plt.subplots_adjust(bottom=0.35)
scatter = ax.scatter(x, y_noise, color='blue', label='Data Points')
line, = ax.plot(x, a_init*np.sin(b_init*x) + c_init*x, color='red', label='Your Curve')
ax.legend()
ax.set_title("CurveCatcher: Interactive Non-linear Regression")

# --- Sliders ---
axcolor = 'lightgoldenrodyellow'
ax_a = plt.axes([0.15, 0.25, 0.65, 0.03], facecolor=axcolor)
ax_b = plt.axes([0.15, 0.20, 0.65, 0.03], facecolor=axcolor)
ax_c = plt.axes([0.15, 0.15, 0.65, 0.03], facecolor=axcolor)

slider_a = Slider(ax_a, 'a', 0.0, 5.0, valinit=a_init)
slider_b = Slider(ax_b, 'b', 0.0, 3.0, valinit=b_init)
slider_c = Slider(ax_c, 'c', -1.0, 2.0, valinit=c_init)

# --- Update function ---
def update(val):
    a = slider_a.val
    b = slider_b.val
    c = slider_c.val
    y_guess = a*np.sin(b*x) + c*x
    line.set_ydata(y_guess)
    ax.set_title(f"CurveCatcher | Current Error: {np.mean((y_guess - y_noise)**2):.2f}")
    fig.canvas.draw_idle()

slider_a.on_changed(update)
slider_b.on_changed(update)
slider_c.on_changed(update)

# --- Reset button ---
resetax = plt.axes([0.8, 0.025, 0.1, 0.04])
button = Button(resetax, 'Reset', color=axcolor, hovercolor='0.975')
def reset(event):
    slider_a.reset()
    slider_b.reset()
    slider_c.reset()
button.on_clicked(reset)

plt.show()