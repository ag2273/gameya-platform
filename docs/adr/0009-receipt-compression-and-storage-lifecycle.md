# 9. Client-Side Receipt Compression and 5-Month Retention Policy

We decided to compress all payment receipt screenshots on the mobile device (max width 1200px, JPEG target ~150KB) prior to upload to Firebase Storage to operate permanently within the free 1 GB tier. In addition, stored receipt photos are automatically scheduled for deletion 5 months after a Gameya transitions to Completed status, ensuring long-term storage sustainability.
