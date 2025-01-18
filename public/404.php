<div class="centered">
    <div class="middle" style="width: 100%;text-align: center;">
        <p style="font-size: xxx-large">
            <?php
            http_response_code(404); //set it
            echo http_response_code() //echo it back
            ?>
        </p>
        <h1>Page not found.</h1>
    </div>
</div>
<style>
    .centered {
        min-height: 50vh;
        display: flex;
        align-items: center; /* Vertical center alignment */
        justify-content: center; /* Horizontal center alignment */
    }
</style>
